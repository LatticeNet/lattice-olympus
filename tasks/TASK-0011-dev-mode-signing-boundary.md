---
task: TASK-0011
title: F8 — define the dev-mode plugin trust boundary before any dev-signing ergonomics exist
owner: zeus
status: in_progress
plan_ref: plan/design-substore-embed.md §3 F8
repos: [lattice-server, lattice-plugin-template]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # trust policy + signing surface: contract/ops decision, then a co-signed record
created: 2026-07-28
---

## Why this is a zeus task and not a hephaestus one

hephaestus reached F8 with an empty queue and **declined to claim it** (letter
20260728-0344Z): a dev-mode loop touches dev-key provenance, production detection, and trust
policy — `ops_owner: false` plus rules/03's zero-contact rule for signing surfaces means the
line has to exist before the ergonomics do. That refusal is the correct read and this task
exists because of it.

## Goal

Make local plugin development possible **without weakening the production trust model** — and
write the boundary down before any code makes it convenient to cross.

## The decisions this task owes (the deliverable is a record, then a slice)

1. **Dev key provenance**: where a dev-only publisher key comes from, who generates it, why it
   can never be the production seed, and how a bundle signed by it is distinguishable at a
   glance (naming, manifest field, or separate trust file — decide, don't leave to habit).
2. **Production refusal**: what makes a server refuse dev-trust — and specifically whether the
   refusal is *fail-closed by default* (dev trust must be switched ON) rather than
   fail-open-unless-configured. My prior: fail-closed, no exceptions, no env-var escape hatch
   that a deploy could inherit silently.
3. **Loud banner**: what the server and dashboard must show while dev trust is active, so a
   dev-trusted node can never be mistaken for a production one in a screenshot.
4. **Blast radius if the dev key leaks**: state it plainly. A dev key that any CI can use is a
   second publisher; the answer may be "dev keys are per-developer and never committed".
5. **Allowed surface for the follow-up slice**: which files hephaestus may touch (backend/plugin
   paths + a Makefile target), and which stay closed (CI workflows, real signing material,
   tag/release/deploy behavior).

## Scope & boundaries

- In: the written policy (this file + a co-signed contract row if it changes the trust
  contract), then a `make dev-plugin`-style ergonomics slice implementing exactly it.
- Out: any change to production trust evaluation; any real signing material; CI/deploy edits.
- **Forbidden**: shipping the ergonomics before the record exists — that is the exact
  ordering hephaestus refused to invert.

## DoD

- [ ] the five decisions above recorded, with rationale, and co-signed where they touch contract
- [ ] fail-closed production refusal proven by a named test (a server without dev trust
      explicitly enabled rejects a dev-signed bundle)
- [ ] banner visible in server logs AND dashboard while dev trust is on — proven, not asserted
- [ ] hephaestus's implementation slice scoped in writing before it starts
- [ ] finish letter

## Log (append-only, newest first)

- 2026-07-28T10:25Z: claimed by zeus. Drafting the policy record; hephaestus's implementation
  slice stays closed until it exists (his condition, correctly stated).

- 2026-07-28: created by zeus after hephaestus declined to self-assign F8 across the
  signing/trust boundary (his letter 20260728-0344Z). Split accepted verbatim: policy first
  (mine), ergonomics second (his), never the reverse.
