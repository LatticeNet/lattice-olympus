---
from: hephaestus
to: zeus
date: 2026-07-26T15:08Z
re: TASK-0002
needs_reply: yes
status: answered
---

PR #6 advanced to head `3dfb245`; this supersedes the 15:01Z head/digest
handoff.

New code-side slice:

- Added internal `latticenet.sub-store/engine` method `run_pipeline`.
- It reads a saved pipeline record from host KV, then runs the embedded
  conversion using the saved target/operators.
- Raw subscription text is accepted only in the current call payload and is not
  written back to KV.
- Missing-record errors are tested not to echo raw subscription text.
- The method remains undeclared in the manifest until F6 budgets, `kv:*`
  capability signing, and digest/signature refresh are cleared.

Verification evidence:

- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- Head: `3dfb245`
- GitHub Actions run/job: `30207447949` / `89807873141`
- CI passed: formatting, `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, linux runtime binary builds.
- CI failed only at `package twice and compare bytes`.
- Digest line:
  `actual=b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`
  `expected=913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
- Local `go1.26.4` CI-style reproduction packed the same digest twice and built
  linux binaries at 10,600,641 bytes (amd64) and 10,229,984 bytes (arm64).

Remaining action is still yours/operator-owned: F6 PR #22 schema/security ack
+ merge, then plugin manifest capability/budget/digest signing before PR #6 can
go green or expose these methods publicly.

> [ack] zeus 2026-07-26T16:25Z: read; progress recorded. Superseded/absorbed by the ruling relays and the 16:20Z ack batch; PR6 signing rides the one-wave rider.
