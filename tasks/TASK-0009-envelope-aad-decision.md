---
task: TASK-0009
title: Envelope v2 — AAD binding decision (ciphertext relocation within state.json)
owner: zeus
status: ready
plan_ref: TASK-0001 finding (server#11 review)
repos: [lattice-server]
branches: []
last_touched_by: principal
depends_on: []
blocked_by_ruling: —   # ruled 2026-08-04T13:50Z (principal): go, envelope v2 with AAD
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

## Ruling (principal, 2026-08-04T13:50Z)

**In model. Go.** The task file's own framing — "state.json write access already implies host
compromise" — is too generous for the deployment shape this project actually ships. Backup tooling
takes and restores whole copies of the state tree (those writes come from ops tooling, not the
server); the sealed file sits beside the audit WAL and the hot store; plugin runtime and cache
directories share the same mount. A restore of a doctored backup is therefore a write by someone
who never had the running host, so the relocation primitive reaches a wider set than a live-host
attacker. Deployment specifics stay in the operator's private notes.

1. **Envelope v2 with AAD** = `lattice.envelope.v2\x00<collection>\x00<owner_id>\x00<field_key>`.
   NUL is a safe separator because every id comes from `id.New(...)` and cannot contain it; the
   leading domain string prevents collision with any future scheme.
2. **Additive migration** (rules/01 §8): v1 stays readable, a v1 value re-seals as v2 on its next
   write, and a bulk re-seal exists only as an explicit operator command — never automatic on boot.
3. **Fail-closed at a version, not a date**: v1 acceptance is removed no earlier than the first
   stable `v0.3.0` train and only when a release note names the removal. A date fires on a fleet
   nobody is watching; a version fires while someone is already reading the notes.
4. **Not in the a5 train.** Hephaestus-owned server task, opened after the a5 deploy settles.

## DoD

- [x] operator ruling recorded (letter + this file's blocked_by_ruling cleared)
- [ ] if go: implementation task re-scoped and assigned; if no-go: rationale recorded in
      memory/notes and this task cancelled with reason

## Log (append-only, newest first)

- 2026-08-04T13:50Z: principal ruled GO with the AAD schema, additive migration, and a
  version-gated (not date-gated) v1 cutoff recorded above; `blocked_by_ruling` cleared and status
  moved `draft → ready`. Letter `messages/inbox/zeus/20260804-1350Z-principal-four-rulings-and-a5-signoff.md`.
  Implementation is explicitly excluded from the alpha-0.2.2a5 train and remains unassigned until
  the deploy settles.

- 2026-07-26T12:05Z: operator ruling batch explicitly left this UNRULED (ordered-list §4) —
  stays `draft`; do not promote until the AAD decision arrives.
- 2026-07-26: drafted by zeus from the TASK-0001 server#11 caveat.
