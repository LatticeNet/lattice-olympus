---
task: TASK-0009
title: Envelope v2 — AAD binding decision (ciphertext relocation within state.json)
owner: zeus
status: draft
plan_ref: TASK-0001 finding (server#11 review)
repos: [lattice-server]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: envelope-v2-aad   # operator decision required before any implementation
needs_ack: yes
created: 2026-07-26
---

## Goal

The secret envelope format (internal/secret/secret.go) seals with NO AAD, so envelopes are
portable between records: an attacker with write access to `state.json` can relocate a
ciphertext to a different record and it still authenticates. Pre-existing, repo-wide (every
encrypted field, not just §9.4 plugin secrets), surfaced by the server#11 review. Binding a
ciphertext to its record identity (e.g. AAD = collection + owner id + key) requires an
envelope v2 plus a migration for every sealed value on disk.

## Decision needed (operator/arbiter)

1. Is the threat in-model? (state.json write access already implies host compromise in most
   deployments — but plugin data dirs and backup handling widen who can write it.)
2. If yes: envelope v2 AAD schema, migration strategy (re-seal on first write vs bulk), and
   whether old envelopes are refused after a deadline (fail-closed date) or grandfathered.

## Scope & boundaries (post-ruling)

- In: envelope v2 with AAD; migration; tests incl. relocation-refused pin.
- Out: master-key rotation (separate concern); KV plaintext semantics.

## DoD

- [ ] operator ruling recorded (letter + this file's blocked_by_ruling cleared)
- [ ] if go: implementation task re-scoped and assigned; if no-go: rationale recorded in
      memory/notes and this task cancelled with reason

## Log (append-only, newest first)

- 2026-07-26: drafted by zeus from the TASK-0001 server#11 caveat.
