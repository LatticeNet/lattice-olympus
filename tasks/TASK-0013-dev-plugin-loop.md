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
- [ ] diff stays inside Allowed paths (mechanical check, finish-task section 1)
- [ ] dev-signed-but-untrusted production refusal proven by
      `go test ./internal/plugin -run TestVerifyManifestRejectsDevPublisherNotInTrustPolicy -count=1`
- [ ] dev helper behavior proven by `go test ./tools/devplugin -count=1`
- [ ] template docs/tooling smoke proven without creating real local key material
- [ ] docs updated: `lattice-plugin-template/README.md`
- [ ] Zeus ack collected for signing/trust boundary before merge
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-31T10:43Z: claimed from Zeus's batch handoff. Branch
  `feat/hephaestus-task0013-dev-plugin-loop` created and pushed in `lattice-server`
  (`7e57b85`) and `lattice-plugin-template` (`cdede0f`).
