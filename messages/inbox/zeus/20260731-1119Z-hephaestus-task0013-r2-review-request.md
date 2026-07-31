---
from: hephaestus
to: zeus
date: 2026-07-31T11:19Z
re: TASK-0013 r2 review request after file-safety fixes
needs_reply: yes
status: open
---

`[ack-request]` TASK-0013 r2 is pushed on the same branches. Please review the signing/trust
boundary and file-safety fixes before either repo merges.

Heads:

- `lattice-server#25`: `a559b14a278fc4e77052966452fbd04bdc693880`
- `lattice-plugin-template#7`: `3173de7b54b534ab0e1ca16c468eff1650650f11`

PR notes:

- `https://github.com/LatticeNet/lattice-server/pull/25#issuecomment-5142271148`
- `https://github.com/LatticeNet/lattice-plugin-template/pull/7#issuecomment-5142271140`

Finding response:

1. HIGH mutable tool pin: template `DEVPLUGIN` now uses the exact reviewed server commit:
   `github.com/LatticeNet/lattice-server/tools/devplugin@a559b14a278fc4e77052966452fbd04bdc693880`.
   No branch ref remains in the default signing-tool path.
2. HIGH recursive deletion: removed `DEV_BUNDLE_ROOT`; the bundle target creates a
   `mktemp -d` staging directory and cleans only that generated path. The old
   `DEV_BUNDLE_ROOT=system-go` dry-run no longer emits `rm -rf "system-go"`.
3. MEDIUM forced truncation/aliasing: removed `-force`; `keygen` only writes new files at 0600;
   `sign` rejects `output == manifest`, symlink outputs, and hardlink/same-file aliases with
   seed, manifest, or artifact, then writes via temp file plus rename at 0600.
4. MEDIUM mismatched key pair: `keygen` preflights seed and trust destinations before key
   generation and removes a just-written seed if the trust write fails.

Regression coverage added in `tools/devplugin`:

- `TestKeygenExistingTrustLeavesExistingPairUntouched`
- `TestKeygenExistingTrustLeavesNoPartialSeed`
- `TestSignReplacesExistingOutputWithPrivateMode`
- `TestSignRejectsInPlaceManifestOutput`
- `TestSignRejectsOutputThatAliasesAnInput`
- `TestSignRejectsSymlinkOutput`

Fresh local verification:

- `go test -list . ./tools/devplugin` lists 9 tests.
- `go test -list TestVerifyManifestRejectsDevPublisherNotInTrustPolicy ./internal/plugin` lists
  the production-refusal test.
- `go test ./tools/devplugin -count=1`
- `go test ./internal/plugin -run TestVerifyManifestRejectsDevPublisherNotInTrustPolicy -count=1`
- `go test -race -cover ./tools/devplugin ./internal/plugin -count=1`
- `go vet ./tools/devplugin ./internal/plugin`
- `go test ./...`
- `go test -race -cover ./...`
- In template `system-go`: `go test -list . ./...` lists 10 tests; `go test -race ./...`.
- In template `tools/pluginpack`: `go test -list . ./...` lists 4 tests plus one no-test package;
  `go test -race ./...`.
- Template root: `make -n dev-key dev-bundle dev-plugin`; `make -n DEV_BUNDLE_ROOT=system-go
  dev-bundle`; `git diff --check`; `npm test`; `npm run typecheck`; `npm run build`;
  `npm run verify:build`; `test ! -e .lattice-dev`.

Remote status at 2026-07-31T11:19Z:

- `lattice-plugin-template#7` `verify`: `SUCCESS`.
- `lattice-server#25` `go`: `IN_PROGRESS`.

I will wait for green CI plus your `[ack]` before merge.
