/*
 * Document-class: Decision
 * Decisions are the result of an successful solve. Decisions describe the actions to be taken (i.e. install this solvable, remove that solvable, ...)
 * to make the solver result effective.
 *
 * Decisions contain an operation (install, update, remove) and the affected Solvable.
 *
 * Additionally they have a _back_ _pointer_ to the Rule which lead to the Decision.
 * This allows to find out about the reasoning for the decision.
 *
 * === Constructor
 * There is no constructor defined for Decision. Decisions are created by accessing
 * the Solver result. See Solver.each_decision
 *
 */

%nodefault _Decision;
%rename(Decision) _Decision;
typedef struct _Decision {} Decision;


%extend Decision {
  /* install a solvable */
  %constant int DECISION_INSTALL = DECISION_INSTALL;
  /* remove a solvable */
  %constant int DECISION_REMOVE = DECISION_REMOVE;
  /* update a solvable */
  %constant int DECISION_UPDATE = DECISION_UPDATE;
  /* obsolete a solvable (remove due to install) */
  %constant int DECISION_OBSOLETE = DECISION_OBSOLETE;
  /* weak decision modifier */
  %constant int DECISION_WEAK = DECISION_WEAK;
  /* free decision modifier */
  %constant int DECISION_FREE = DECISION_FREE;


  ~Decision()
  { decision_free( $self ); }
  Solver *solver()
  { return $self->solver; }
  /*
   * the decision operation, one of +Satsolver::DECISION_*+
   */
  int op()
  { return $self->op; }
  /*
   * a string representation of the operation
   */
  const char *op_s()
  { switch ($self->op) {
      case DECISION_INSTALL: return "install";
      case DECISION_REMOVE: return "remove";
      case DECISION_UPDATE: return "update";
      case DECISION_OBSOLETE: return "obsolete";
      case DECISION_INSTALL|DECISION_FREE: return "free install";
      default: break;
    }
    return "unknown";
  }
  /*
   * The solvable affected by the decision
   */
  XSolvable *solvable()
  { return xsolvable_new( $self->solver->pool, $self->solvable ); }
  /*
   * The rule which lead to the decision
   * might be +nil+
   */
  Rule *rule()
  { if ($self->rule > $self->solver->rules)
      return $self->rule;
    return NULL;
  }

#if defined(SWIGRUBY)
  VALUE
#endif
#if defined(SWIGPYTHON)
  PyObject *
#endif
#if defined(SWIGPERL)
  SV *
#endif
  /*
   * Explain a decision
   *
   * returns 4-element Array [<SOLVER_PROBLEM_xxx>, Relation, Solvable, Solvable]
   *
   * call-seq:
   *  decision.explain -> [<SOLVER_PROBLEM_xxx>, Relation, Solvable, Solvable]
   *
   */
  __type explain()
  {
    Swig_Type result = Swig_Null;
    Solver *solver = $self->solver;
    Id rule = $self->rule - solver->rules;
    if (rule > 0) {
      Id depp = 0, sourcep = 0, targetp = 0;
      SolverProbleminfo pi = solver_ruleinfo(solver, rule, &sourcep, &targetp, &depp);
      result = Swig_Array();
/*      fprintf(stderr, "Rule %d: [pi %d, rel %d, source %d, target %d]\n", rule, pi, depp, sourcep, targetp); */
      Swig_Append(result, Swig_Int(pi));
      Swig_Append(result, SWIG_NewPointerObj((void*)relation_new(solver->pool, depp), SWIGTYPE_p__Relation, 0));
      Swig_Append(result, SWIG_NewPointerObj((void*)xsolvable_new(solver->pool, sourcep), SWIGTYPE_p__Solvable, 0));
      Swig_Append(result, SWIG_NewPointerObj((void*)xsolvable_new(solver->pool, targetp), SWIGTYPE_p__Solvable, 0));
    }
    return result;
  }
}

