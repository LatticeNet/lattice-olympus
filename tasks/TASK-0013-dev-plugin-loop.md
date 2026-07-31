---
task: TASK-0013
title: Implement the dev-key plugin loop without weakening production trust
owner: hephaestus
status: in_progress
plan_ref: TASK-0011 Decision 5
repos: [lattice-server, lattice-plugin-template]
branches: [feat/hephaestus-task0013-dev-plugin-loop]
last_touched_by: hephaestus
depends_on: []
blocked_by_ruling: -
needs_ack: yes
created: 2026-07-31
---

## Goal

Give plugin developers a local dev-key loop that exercises the real signature path while keeping
production fail-closed. Observable result: the template repo can generate a local per-developer
trust file and dev-sign a local bundle through tooling, while a server trust policy that does
not list `dev.<handle>` rejects that dev-signed bundle.

## Scope & boundaries

- In:
  - dev-only key/trust/sign helper under `lattice-server/tools/**`, reusing server signing code
    rather than duplicating canonical payload rules.
  - template Makefile/docs glue for local developers.
  - `.gitignore` protection for generated local trust files and key material.
  - test-only proof that a dev publisher not present in trust policy is rejected.
- Out:
  - CI workflows.
  - release signing, release tags, package publishing, deployments, or GitHub Actions dispatch.
  - production trust files.
  - `cmd/pluginsign` behavior.
  - `TrustPolicy` evaluation behavior.
  - dashboard banner work, owned by TASK-0012/Athena.
- **Allowed paths** (globs - checked mechanically at finish):
  - `lattice-server/tools/**`
  - `lattice-server/internal/plugin/plugin_test.go`
  - `lattice-plugin-template/Makefile`
  - `lattice-plugin-template/README.md`
  - `lattice-plugin-template/.gitignore`
- **Forbidden**:
  - do not commit any private key, seed, local trust JSON, signature secret, or production trust
    file.
  - do not run `pluginsign`, push tags, edit workflows, or touch live/production systems.
  - do not change manifest trust evaluation semantics.

## Notes

- Handoff: `messages/inbox/hephaestus/20260731-1021Z-zeus-review-batch-and-f8-handoff.md`.
- Policy source: `tasks/TASK-0011-dev-mode-signing-boundary.md`, operator-ratified 2026-07-28.
- Trust gate is Zeus-reviewed because this touches plugin signing/trust ergonomics.
- Tool verification may use temporary test keys inside automated tests; no operational key
  generation or signing run is authorized.

## DoD

- [ ] merged into integration in `lattice-server`
- [ ] merged into integration in `lattice-plugin-template`
- [x] diff stays inside Allowed paths (mechanical check, finish-task section 1)
- [x] dev-signed-but-untrusted production refusal proven by
      `go test ./internal/plugin -run TestVerifyManifestRejectsDevPublisherNotInTrustPolicy -count=1`
- [x] dev helper behavior proven by `go test ./tools/devplugin -count=1`
- [x] template docs/tooling smoke proven without creating real local key material
- [x] docs updated: `lattice-plugin-template/README.md`
- [ ] Zeus ack collected for signing/trust boundary before merge
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-31T11:19Z: r2 pushed after Zeus `[request-changes]`: `lattice-server#25`
  `a559b14a278fc4e77052966452fbd04bdc693880` removes `-force`, rejects symlink/hardlink/input
  alias outputs, writes mode-0600 output atomically, and adds six file-safety regressions;
  `lattice-plugin-template#7` `3173de7b54b534ab0e1ca16c468eff1650650f11` pins `DEVPLUGIN` to the
  exact server commit and replaces caller-controlled bundle deletion with `mktemp -d` staging.
  Fresh local gates passed; template CI green; server CI still in progress. Zeus r2 ack requested
  by `messages/inbox/zeus/20260731-1119Z-hephaestus-task0013-r2-review-request.md`.
- 2026-07-31T11:09Z: draft PRs opened: `lattice-server#25` at
  `18fe3a0c1bceb06ec74e3bc0d7d4bf7352337562` and `lattice-plugin-template#7` at
  `384ca69fb53650e46bc5d6cfca528ba48e8426f7`. Local final gates passed, including server
  `go test -race -cover ./...` and template UI `npm ci && npm test && npm run typecheck &&
  npm run build && npm run verify:build`. CI was in progress at PR creation; Zeus ack requested
  by `messages/inbox/zeus/20260731-1109Z-hephaestus-task0013-review-request.md`.
- 2026-07-31T10:57Z: implementation pushed. `lattice-server` commit `18fe3a0` adds
  `tools/devplugin` plus fail-closed dev publisher proof; `lattice-plugin-template` commit
  `384ca69` adds the Makefile/docs/gitignore local loop. Verified allowed paths, target tests,
  server `go test ./...`, server `go vet ./...`, template Go race tests, Make dry-run, and no
  generated `.lattice-dev/`.
- 2026-07-31T10:43Z: claimed from Zeus's batch handoff. Branch
  `feat/hephaestus-task0013-dev-plugin-loop` created and pushed in `lattice-server`
  (`7e57b85`) and `lattice-plugin-template` (`cdede0f`).
