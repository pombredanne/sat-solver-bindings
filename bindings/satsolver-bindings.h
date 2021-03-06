#include "generic_types.h"

/* satsolver core includes */
#include "policy.h"
#include "bitmap.h"
#include "evr.h"
#include "hash.h"
#include "poolarch.h"
#include "pool.h"
#include "poolid.h"
#include "pooltypes.h"
#include "queue.h"
#include "solvable.h"
#include "solver.h"
#include "repo.h"
#include "repo_solv.h"
#include "repo_rpmdb.h"
#include "transaction.h"

/* satsolver application layer includes */
#include "applayer.h"
#include "xsolvable.h"
#include "xrepokey.h"
#include "relation.h"
#include "dependency.h"
#include "job.h"
#include "request.h"
#include "decision.h"
#include "problem.h"
#include "solution.h"
#include "covenant.h"
#include "ruleinfo.h"
#include "step.h"

#if SATSOLVER_VERSION > 1701
/* satsolver tools layer includes */
#include "common_write.h"
#endif
