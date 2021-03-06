require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
#
# After successful solving, the solver returns the result as list of Decisions.
#
# A Decision consitst of
#  - an operation (see below)
#  - a solvable (affected by the operation)
#  - a reason (the reason for the decision)
#
# Operation can be one of
#  - DEC_INSTALL
#     install solvable, required by 'reason' (if reason is set)
#  - DEC_REMOVE
#     remove solvable, updated/obsoleted/conflicted by 'reason' (if reason is set)
#  - DEC_OBSOLETE
#     auto-remove solvable through an obsoletes/update coming from 'reason'
#  - DEC_UPDATE
#     install solvable, thereby updating 'reason'
#
# The number of decision steps is available through Solver.decision_count
#

# test Decisions
class DecisionTest < Test::Unit::TestCase
  def test_decision
    pool = Satsolver::Pool.new
    assert pool
    
    installed = pool.create_repo( 'system' )
    assert installed
    installed.create_solvable( 'A', '0.0-0' )
    installed.create_solvable( 'B', '1.0-0' )
    solv = installed.create_solvable( 'C', '2.0-0' )
    solv.requires << Satsolver::Relation.new( pool, "D", Satsolver::REL_EQ, "3.0-0" )
    installed.create_solvable( 'D', '3.0-0' )
    
    # installed: A-0.0-0, B-1.0-0, C-2.0-0, D-3.0-0
    #  C-2.0-0 requires D-3.0-0
    
    repo = pool.create_repo( 'test' )
    assert repo
    
    solv1 = repo.create_solvable( 'A', '1.0-0' )
    assert solv1
    solv1.obsoletes << Satsolver::Relation.new( pool, "C" )
    solv1.requires << Satsolver::Relation.new( pool, "B", Satsolver::REL_GE, "2.0-0" )
    
    solv2 = repo.create_solvable( 'B', '2.0-0' )
    assert solv2

    solv3 = repo.create_solvable( 'CC', '3.3-0' )
    solv3.requires << Satsolver::Relation.new( pool, "A", Satsolver::REL_GT, "0.0-0" )
    repo.create_solvable( 'DD', '4.4-0' )

    request = pool.create_request
    request.install( solv3 )
    request.remove( "D" )
    
    pool.installed = installed
    solver = pool.create_solver( )
    solver.allow_uninstall = true;
#    @pool.debug = 255
    solver.solve( request )
    puts "** Problems found" if solver.problems?
    assert solver.decision_count > 0
    i = 0
    solver.each_decision { |d|
      i += 1
      case d.op
      when Satsolver::DECISION_INSTALL
	puts "#{i}: Install #{d.solvable}\n\t#{d.ruleinfo.command_s}: #{d.ruleinfo}"
      when Satsolver::DECISION_REMOVE
	puts "#{i}: Remove #{d.solvable}\n\t#{d.ruleinfo.command_s}: #{d.ruleinfo}"
      when Satsolver::DECISION_OBSOLETE
	puts "#{i}: Obsoleted #{d.solvable}\n\t#{d.ruleinfo.command_s}: #{d.ruleinfo}"
      when Satsolver::DECISION_UPDATE
	puts "#{i}: Update to #{d.solvable}\n\t#{d.ruleinfo.command_s}: #{d.ruleinfo}"
      else
	puts "#{i}: Decision op #{d.op}"
      end
    }
  end
end
