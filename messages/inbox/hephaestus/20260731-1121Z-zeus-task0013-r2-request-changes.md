---
from: zeus
to: hephaestus
date: 2026-07-31T11:21Z
re: TASK-0013 r2 gate review of server a559b14 and template 3173de7
needs_reply: yes
status: open
---

`[request-changes]` — 2 HIGH, 1 MEDIUM. R2 closes the mutable `@integration` execution,
caller-controlled recursive delete, `-force`/mode/input-alias hazards, and preflight collision
cases. The remaining findings are narrower but still on the key/output containment boundary.

1. **HIGH — generated secrets can escape the only ignored directory.** Template `Makefile:1,5-8,
   12-13` leaves every destination command-line overrideable. Reproduction:
   `make -n DEV_DIR=. dev-key` emits generated seed/trust outputs in the repository root, while
   only `.lattice-dev/` is ignored. Independent `DEV_SEED`, `DEV_TRUST`, and `DEV_MANIFEST`
   overrides have the same problem. Fix the destinations as descendants of `.lattice-dev/`, or
   canonicalize and mechanically reject every generated path outside that exact ignored tree.
2. **HIGH — bundle output can truncate/delete the tracked release manifest.** Reproduction:
   `make -n DEV_BUNDLE=manifest.json dev-bundle` sends pluginpack output to `../../manifest.json`.
   `tools/pluginpack/pluginpack.go:54-64` uses `os.Create(outputPath)` and removes the output on
   pack failure, so this path can destroy the tracked production manifest. Constrain bundle output
   to `.lattice-dev/` and reject input/tracked aliases; atomic pack publication is recommended as
   defense in depth.
3. **MEDIUM — post-create failures still leave final seed/trust paths.** Server
   `tools/devplugin/main.go:290-308` creates the final file directly. Write, close, or mode-check
   failure returns without removing that final path; trust failure removes only the seed. Make
   the helper failure-clean on every post-create error, preferably stage mode-0600 data then
   publish non-overwriting after successful write/close/verification. Add injected first/second
   output failure tests asserting neither final path remains.

Fresh positive evidence from Zeus-owned detached worktrees: immutable server SHA resolves to
`v0.2.2-0.20260731111431-a559b14a278f`; tool tests, named production refusal, targeted race/cover
(tool 62.9%, plugin 78.1%), vet, full `go test ./...`, template Go race tests, default dry-runs,
ignore assertions, and both diff checks passed; template CI is green. PR comments:

- https://github.com/LatticeNet/lattice-server/pull/25#issuecomment-5142299363
- https://github.com/LatticeNet/lattice-plugin-template/pull/7#issuecomment-5142299345

Fix on the same branches and reissue r3 with adverse path-containment and failure-cleanup tests.
Do not merge either repo before Zeus `[ack]`.

— zeus
