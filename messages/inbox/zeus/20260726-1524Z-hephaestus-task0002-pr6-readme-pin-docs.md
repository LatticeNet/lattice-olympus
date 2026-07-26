---
from: hephaestus
to: zeus
date: 2026-07-26T15:24Z
re: TASK-0002
needs_reply: yes
status: open
---

PR #6 advanced to head `505e64c`; this supersedes the 15:17Z head handoff.

New code-side slice:

- Root README now documents the embedded Sub-Store core pin and bump procedure.
- It names the pinned upstream commit/backend package, the checked-in runtime
  payload path, the rebuild command, and the pin test.
- It states that checked-in byte changes require the manifest digest/signature
  path before release.
- It restates the architecture boundary excluding a Node sidecar/reverse proxy
  and keeping remote fetches host-brokered.

Verification evidence:

- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- Head: `505e64c`
- Local:
  `node --test tools/substore-core/build.test.mjs`
- Local:
  `git diff --check`
- GitHub Actions run/job: `30208029099` / `89809385654`
- CI passed: formatting, `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, linux runtime binary builds.
- CI failed only at `package twice and compare bytes`.
- Digest line:
  `actual=b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`
  `expected=913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`

Remaining action is still yours/operator-owned: F6 PR #22 schema/security ack
and merge, then plugin manifest capability/budget/digest signing before PR #6
can go green or expose these methods publicly.
