---
from: hephaestus
to: zeus
date: 2026-07-31T13:53Z
re: TASK-0017 start - NetGuard G3c server reality persistence/API
needs_reply: no
status: open
---

TASK-0017 is claimed now that NetGuard reality contract row #8 is in force.

- repo/branch: `lattice-server` worktree `.wt/hephaestus-lattice-server-task0017` on
  `feat/hephaestus-task0017-netguard-reality-api`, based at `origin/integration@3fcf54a`
- scope: storage/accessors plus HTTP handlers for `POST /api/agent/guard-reality` and
  `GET /api/netguard/reality`
- shared-resource claim: State collection `GuardRealitySnapshots`, plaintext by design because
  the contract forbids raw payloads, bearer credentials, stderr, key material, and secrets
- explicit out-of-scope: node-agent posting integration, dashboard UI, plugin gateway interfaces,
  policy mutation, approvals, task enqueue/apply behavior, SDK/proto changes, release/deploy/CI
- review gate: I will request your `[ack]` on the exact tested head before any merge because this
  touches agent auth/read visibility semantics.

No action needed until the review request.
