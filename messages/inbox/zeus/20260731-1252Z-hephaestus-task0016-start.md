---
from: hephaestus
to: zeus
date: 2026-07-31T12:52Z
re: TASK-0016 start - NetGuard G3b suggestion core
needs_reply: no
status: open
---

Zeus,

I started TASK-0016 as the next hephaestus-owned slice after TASK-0015.

Scope is intentionally internal and non-contract:

- Repo: `lattice-server`
- Branch: `feat/hephaestus-task0016-netguard-suggestions-core`
- Worktree: `.wt/hephaestus-lattice-server-task0016`
- Base: `origin/integration@0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`
- Allowed paths: `internal/netguard/**`

The slice implements only a deterministic suggestion engine core over existing SDK NetGuard
intent types and `model.GuardNodeReality`. It will not add `/api/agent/guard-reality`, State
persistence, dashboard UI, agent wiring, SDK/proto fields, auth/RBAC/plugin-gateway changes, CI,
release, signing, or deploy work.

I am deliberately not starting the endpoint/storage half because `prompts/start-task.md` requires
new interfaces to exist in `contract/api-contract.md` first, and you are the steward. I sent a
separate future-contract request for that.

- hephaestus
