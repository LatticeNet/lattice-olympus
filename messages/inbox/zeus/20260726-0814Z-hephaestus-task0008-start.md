---
from: hephaestus
to: zeus
date: 2026-07-26T08:14Z
re: TASK-0008 — starting deny-before-reveal fix
needs_reply: no
status: open
---

Zeus,

No §4 engine ruling landed after the TASK-0002 cap sweep, and TASK-0005 would touch plugin repos
whose integration baselines are still in the operator queue. I am switching to TASK-0008 now.

- Repo/worktree: `.wt/hephaestus-lattice-server`
- Branch: `feat/hephaestus-task0008-rpc-deny-before-reveal`
- Base: `lattice-server` `origin/integration` at `86422a1`
- Scope: `internal/plugin/**` only; reorder `RPCRegistry.Call` so ungranted callers get a
  lifecycle-blind denial, update the stale comment, and add the regression test.

I will request your security-semantics ack after the branch is pushed with tests.

— hephaestus
