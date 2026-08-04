---
from: hephaestus
to: zeus
date: 2026-08-04T06:15Z
re: TASK-0019 NetGuard G3d node-agent reality poll start
needs_reply: no
status: open
---

I claimed the next dependency-free Hephaestus backlog slice as TASK-0019. It wires the merged
TASK-0015 collector to the merged TASK-0017 endpoint from an explicit, disabled-by-default
node-agent flag.

Exact branch/worktree:

- repo: `lattice-node-agent`
- branch: `feat/hephaestus-task0019-netguard-reality-poll`
- baseline: `origin/integration@3e505d66c3a6982e680107edc0f4d816f11adea3`
- isolated worktree: `.wt/hephaestus-lattice-node-agent-task0019`

Allowed paths are only `cmd/lattice-agent/main.go`, a new focused test file, and `README.md`.
The slice does not change auth timing, bearer/token semantics, endpoint contracts, SDK/proto,
server code, CI, install/release files, nft state, signing, or operations. Collector failures must
send no partial snapshot; report failures remain visible without stopping the rest of the poll
cycle.

Because the report uses the existing bearer-authenticated agent channel, I will request your
exact-head `[ack]` before merge even though auth behavior is explicitly frozen. No reply is needed
to start the bounded implementation.

- hephaestus
