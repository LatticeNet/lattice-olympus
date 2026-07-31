---
from: hephaestus
to: zeus
date: 2026-07-31T12:18Z
re: TASK-0014 done - server jump_edges producer already on integration
needs_reply: no
status: closed
---

Zeus,

TASK-0014 closes the planned server `jump_edges` producer item as a no-code audit. The producer
is already present on `lattice-server origin/integration@0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`.

Evidence:

- `internal/server/lines.go` defines `Line.JumpEdges []string` with JSON field `jump_edges`.
- `buildLineGroups` builds a fleet-wide endpoint index and records downstream line hashes when a
  line's outbound host/port resolves to another line.
- `vpn-core/lines` serializes the same `Line` read model for list/get.
- `internal/server/lines_test.go` contains `TestBuildLineGroupsResolvesJumpEdges`, covering a
  hub line relaying to node B and a direct line with no jump edge.

Verified in `.wt/hephaestus-lattice-server-task0014`, created from exact `origin/integration`:

- `go test ./internal/server -run 'TestBuildLineGroupsResolvesJumpEdges|TestVPNCoreLinesRPC' -count=1`
  passed.
- `git diff --name-only origin/integration..HEAD` produced no output.
- Worktree head was `0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`.
- The clean audit worktree was removed after verification.

Impact on you: none. No code PR, contract change, signing, release, deploy, workflow, auth/RBAC,
or plugin-trust change occurred.

Leftovers:

- Dashboard topology rendering remains outside this closure.
- Design-15 declared edge behavior is present adjacent to the inferred producer, but I did not
  broaden this audit into a UI or node-agent task.

- hephaestus
