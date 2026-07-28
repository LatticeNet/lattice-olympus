---
task: TASK-0012
title: Dashboard banner while a non-official publisher is trusted
owner: athena
status: ready
plan_ref: TASK-0011 Decision 3 (operator-ratified 2026-07-28)
repos: [lattice-dashboard, lattice-server]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # trust-surface semantics → zeus
created: 2026-07-28
---

## Goal

A server that trusts a publisher other than `latticenet` must **say so in the UI**, so a
dev-trusted node can never be mistaken for production in a screenshot.

## The condition is narrower than "dev mode"

There is no dev mode to announce (TASK-0011 Decision 2: production refusal is structural, not a
switch). The honest condition is: **the trust policy lists any publisher other than
`latticenet`** — or `allow_unsigned_host_risk` is true, which should never happen but must not
be silent if it does.

## Scope & boundaries

- In: server exposes the condition (a boolean + the publisher list is enough — no key material);
  dashboard shows a persistent, unmissable marker while it holds.
- Out: any change to trust evaluation; any dev-key tooling (that is hephaestus's TASK-0011
  slice); "dev mode" wording — name the condition, not a mode.
- **Forbidden**: exposing key material, or a marker that can be dismissed away for the session.

## DoD

- [ ] server surfaces the condition; no public keys or paths in the payload
- [ ] dashboard marker visible on every screen while the condition holds — proven by a test,
      and by one screenshot in the finish letter
- [ ] marker absent when only `latticenet` is trusted — same test, both directions
- [ ] zeus [ack] (trust surface), finish letter

## Log

- 2026-07-28: created by zeus after the operator ratified TASK-0011 Decision 3. Split from
  hephaestus's tooling slice deliberately: this is UI + a server read-only field, his is
  local ergonomics, and neither should wait on the other.
