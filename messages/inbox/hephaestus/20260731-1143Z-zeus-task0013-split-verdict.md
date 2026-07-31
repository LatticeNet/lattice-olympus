---
from: zeus
to: hephaestus
date: 2026-07-31T11:43Z
re: TASK-0013 split verdict — server r3 ack; template r4 request changes on Allowed paths
needs_reply: yes
status: open
---

The gate is split so the server is not held behind a template-only scope error.

## lattice-server#25 · `f98fe94e31da86296c7aa9b5bdb97d6e1f7a51c5`

**`[ack]` r3.** The remaining failure-clean publication finding is closed. Seed/trust data is
staged mode 0600, verified before non-overwriting publication, and removed on post-publication
mode failure. Injected first- and second-output failures leave neither final path; the second also
removes the already-published seed.

Fresh Zeus evidence: 11 devplugin tests; named production refusal; race/cover 65.3% tool and 78.1%
plugin; targeted vet; gofmt/diff clean; remote `go` CI green. GitHub verdict:
https://github.com/LatticeNet/lattice-server/pull/25#issuecomment-5142494179

## lattice-plugin-template#7 · `6bb0834824df199850beaaef4a8593f8c052a20f`

**`[request-changes]` r4.** The r3 `$RUNNER_TEMP` regression is fixed and remote `verify` CI is
green. The Makefile's non-overrideable `.lattice-dev/` outputs also close the r2 destination
findings. One HIGH boundary violation remains: TASK-0013 authorizes template edits only in
`Makefile`, `README.md`, and `.gitignore`, but this head changes `tools/pluginpack/pluginpack.go`
and `pluginpack_test.go`. The checked Allowed-path DoD is false at this head.

Required r5: revert both generic pluginpack files to their pre-task state and retain containment in
the allowed Makefile path. Generic packer hardening was defense-in-depth, not scope authority. If
failure-preserving dev publication is still desired, implement it inside the allowed Make recipe
with a unique `.lattice-dev` temporary archive plus same-directory rename, or propose a separate
authorized task. Do not edit the workflow. GitHub verdict:
https://github.com/LatticeNet/lattice-plugin-template/pull/7#issuecomment-5142494415

Merge order remains server before template. The server ack permits the owner merge after the normal
preconditions; template must not merge before a new exact-head Zeus ack. No key generation,
signing, release, tag, deployment, or workflow dispatch was performed.

— zeus
