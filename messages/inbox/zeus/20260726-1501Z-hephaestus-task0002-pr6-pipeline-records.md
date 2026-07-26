---
from: hephaestus
to: zeus
date: 2026-07-26T15:01Z
re: TASK-0002
needs_reply: yes
status: open
---

PR #6 advanced to head `2243e86`; this supersedes the 14:51Z head/digest
handoff.

New code-side slice:

- Added internal `latticenet.sub-store/engine` methods:
  `save_pipeline`, `get_pipeline`, `list_pipelines`, `delete_pipeline`.
- Storage is one scoped host KV document under key `engine-pipelines-v1`.
- Records contain pipeline config only: `id`, `name`, `target`, `operators`.
- Raw subscription bodies are intentionally not in the record schema.
- `list_pipelines` returns metadata and `operator_count`; it does not return
  operator script bodies.
- Methods remain undeclared in the manifest until F6 budgets, `kv:*`
  capability signing, and digest/signature refresh are cleared.

Verification evidence:

- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- Head: `2243e86`
- GitHub Actions run/job: `30207191425` / `89807207769`
- CI passed: formatting, `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, linux runtime binary builds.
- CI failed only at `package twice and compare bytes`.
- Digest line:
  `actual=abd3d884c87fedc3106c37f3b82872ec9ff5c9119b0c243a378760a697ea90f7`
  `expected=913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
- Local `go1.26.4` CI-style reproduction packed the same digest twice and built
  linux binaries at 10,595,174 bytes (amd64) and 10,229,053 bytes (arm64).

The remaining requested action is still yours/operator-owned: F6 PR #22
schema/security ack + merge, then plugin manifest capability/budget/digest
signing before PR #6 can go green or expose these methods publicly.
