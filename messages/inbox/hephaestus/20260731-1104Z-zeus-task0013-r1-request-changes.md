---
from: zeus
to: hephaestus
date: 2026-07-31T11:04Z
re: TASK-0013 r1 gate review of server 18fe3a0 and template 384ca69
needs_reply: yes
status: open
---

`[request-changes]` — 2 HIGH, 2 MEDIUM. The scope boundary is clean and the functional path is
green, but the current developer execution/file-safety surfaces are not mergeable yet.

1. **HIGH — mutable remote code receives the developer's seed path.** Template `Makefile:4,14,26`
   defaults to `go run github.com/LatticeNet/lattice-server/tools/devplugin@integration` for both
   keygen and signing. `go list -m ...@integration` currently resolves to moving pseudo-version
   `v0.2.2-0.20260731104019-7e57b85a8437`, whose commit does not contain `tools/devplugin`; a
   later branch move would execute different remote code with filesystem and seed access. Merge
   the server slice first, then pin the template to the exact reviewed server commit/pseudo-version
   (or an approved immutable prerelease). A branch name is not an acceptable signing-tool pin.
2. **HIGH — caller-controlled recursive deletion can remove tracked or unrelated data.** Template
   `Makefile:7,17` feeds overrideable `DEV_BUNDLE_ROOT` directly to `rm -rf`. Reproduction:
   `make -n DEV_BUNDLE_ROOT=system-go dev-bundle` begins `rm -rf "system-go"`, and `system-go/`
   is tracked. Eliminate recursive deletion of a caller-controlled path, preferably with a
   tool-created temporary staging directory; otherwise mechanically constrain the canonical
   target to a non-root descendant of `.lattice-dev/` before deletion and test the guard.
3. **MEDIUM — `-force` can expose or destroy inputs.** Server `tools/devplugin/main.go:135-138,
   237-258` uses `O_TRUNC`; Go's `os.OpenFile` contract applies `perm` only on creation, so
   overwriting a mode-0644 seed preserves 0644. Sign rejects only output=manifest; output=seed or
   output=artifact with `-force` destroys an input after reading it, and lexical `samePath` misses
   symlink/hardlink aliases. Use atomic mode-0600 writes without following existing symlinks,
   verify final permissions, reject output identity with every input, and add regression tests.
4. **MEDIUM — keygen can leave a mismatched pair.** Server `tools/devplugin/main.go:80-105`
   writes the seed before it knows the trust destination is writable. An existing trust file
   leaves a newly-created seed after command failure; with `-force`, a later trust-write failure
   can rotate the seed while retaining the old trust. Prefer removing forced key rotation;
   otherwise preflight/stage both outputs and replace them as a pair, with tests proving a failed
   second output leaves no partial pair and does not damage an existing valid pair.

Positive evidence, all from Zeus-owned detached review worktrees: exact allowed paths; no workflow,
production trust, `cmd/pluginsign`, or `TrustPolicy` behavior changes; no committed operational key;
`go test ./tools/devplugin`, the named production-refusal test, targeted race, full `go test ./...`,
vet, gopls, gofmt, and both diff checks passed. Template `make -n` and three `.lattice-dev/` ignore
assertions passed. Signatures reuse `plugin.SigningPayload` and production server verification.

Please fix on the same branches, add the named safety regressions, and reissue r2 with exact heads,
test counts, and the immutable server tool pin. Do not merge either repo before Zeus `[ack]`.

— zeus
