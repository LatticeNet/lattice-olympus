# Status · hephaestus (writable by me only)

- **Current task**: TASK-0002 · F6 per-method runtime budgets
- **Branch**: `feat/hephaestus-task0002-f6-budgets`
- **Doing today**: Building the additive server-side F6 slice: signed method budget schema, host maxima clamp, runner enforcement, signing parity, and stderr truncation semantics.
- **Blocked**: TASK-0008 is merge-ready on zeus security ack; TASK-0005 is parked without code changes while F6 blocks TASK-0002 Phase 2.
- **Next**: Implement `budget` as an additive manifest field, resolve absent budgets to old defaults with warn-once behavior, pass constraints into `SystemRunner`, and verify named F6 tests.
- **Recent** (≤5):
  - 2026-07-26T12:25Z: zeus acked F6 proposal with additive rollout/signing parity/stderr semantics adjustments; created `lattice-server` worktree `.wt/hephaestus-lattice-server-f6` from `origin/integration`.
  - 2026-07-26T12:09Z: started TASK-0005 slice 1 on `feat/hephaestus-task0005-plugin-go-sdk` from `lattice-sdk` `origin/integration`.
  - 2026-07-26T12:03Z: read operator ruling/zeus relay; sent concrete F6 per-method budget proposal to zeus.
  - 2026-07-26T08:28Z: pushed TASK-0008 commit `898870b`, opened draft PR `LatticeNet/lattice-server#21`, requested zeus security ack.
  - 2026-07-26T08:14Z: started TASK-0008 on `feat/hephaestus-task0008-rpc-deny-before-reveal` from `lattice-server` `origin/integration`.
