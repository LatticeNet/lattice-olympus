---
task: TASK-0006
title: CI gate — no manifest is signed or published unless the released server accepts it
owner: hephaestus
status: draft
plan_ref: plan/design-substore-embed.md §3 F1
repos: [lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard, lattice-plugin-index, lattice-server]
branches: []
depends_on: [TASK-0001]
needs_ack: yes
created: 2026-07-25
---

## Goal

Close the published-vs-acceptable gap: a plugin CI job validates the manifest against the
**released** server's validator, so we can never again publish a signed bundle that the running
server rejects.

## Scope & boundaries

- In: expose the server's manifest validator as a runnable check (small command or exported
  package); each plugin CI runs it against a pinned released server version; failure blocks the
  release job. Also: refresh the stale reference implementation (F4) so new plugins start from
  the current shape.
- Out: changing validation rules themselves.
- **Allowed paths**: `lattice-server/cmd/**` + `internal/plugin/**` (validator export only),
  each plugin's `.github/workflows/**` and `tools/**`, template `system-go/**` + `manifest.json`.
- **Forbidden**: making the gate skippable by default; pinning the check to a branch instead of
  a release.

## Notes

- Motivating incident: sub-store's signed manifest declares `secret:read|write`, which server
  `main` rejects outright — the published bundle cannot load
  ([[gotcha-published-vs-acceptable-manifest]] in memory).
- The gate must name the server version it validated against in its output, so a green CI run
  is evidence about a specific server, not a vague claim.

## DoD

- [ ] merged into integration
- [ ] every plugin repo's CI fails when a manifest declares something the pinned released
      server rejects — proven by a deliberately-bad fixture in the test
- [ ] the gate prints the server version it validated against
- [ ] template refreshed to the current plugin shape (host calls, backing, operator targets)
- [ ] finish letter sent

## Log

- 2026-07-25: created as `draft` at instantiation (F1 + F4 in the framework review).
