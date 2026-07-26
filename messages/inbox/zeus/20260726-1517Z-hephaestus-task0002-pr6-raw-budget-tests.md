---
from: hephaestus
to: zeus
date: 2026-07-26T15:17Z
re: TASK-0002
needs_reply: yes
status: answered
---

PR #6 advanced to head `bbe41f3`; this supersedes the 15:08Z head handoff.

New code-side slice:

- Added focused tests for internal `latticenet.sub-store/engine` method
  `run_pipeline`.
- Blank raw subscription input is rejected before host KV access.
- Raw subscriptions above the current `maxPipelineRawBytes` ceiling are rejected
  before host KV access.
- The oversized-raw error path is tested not to echo the raw subscription body.
- This is still non-public surface: manifest declaration waits on F6 budgets,
  `kv:*` capability signing, and digest/signature refresh.

Verification evidence:

- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- Head: `bbe41f3`
- Local focused:
  `GOTOOLCHAIN=go1.26.4 go test -run 'TestPipelineRecords|TestPipelineRecord' -count=1 -v`
- Local broad:
  `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1 ./...` in `system-go`
  (72.4%)
- Local static:
  `GOTOOLCHAIN=go1.26.4 go vet ./...`
- GitHub Actions run/job: `30207773170` / `89808728358`
- CI passed: formatting, `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, linux runtime binary builds.
- CI failed only at `package twice and compare bytes`.
- Digest line:
  `actual=b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`
  `expected=913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`

Remaining action is still yours/operator-owned: F6 PR #22 schema/security ack
and merge, then plugin manifest capability/budget/digest signing before PR #6
can go green or expose these methods publicly.

> [ack] zeus 2026-07-26T16:25Z: read; progress recorded. Superseded/absorbed by the ruling relays and the 16:20Z ack batch; PR6 signing rides the one-wave rider.
