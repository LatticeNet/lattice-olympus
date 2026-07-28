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

## POLICY — RATIFIED by the operator 2026-07-28 (both open questions answered "yes")

Three facts from `internal/plugin/plugin.go` + `cmd/lattice-server/main.go`, not from memory:

- `TrustPolicy.AllowUnsignedHostRisk` already exists. Zero value is **false** (fail-closed), it
  can be set **only** through the trust-policy JSON file (`LATTICE_PLUGIN_TRUST` names the
  file), and startup logs `WARNING: … UNSIGNED host-risk plugins will load`.
- `TrustedPublishers` is a **map**. The trust model already supports more than one publisher.
- The warning is a log line. Nothing in the dashboard says a server is running relaxed trust.

### Decision 1 — the dev loop must NOT use `AllowUnsignedHostRisk`

That flag disables signature enforcement for **every** host-risk plugin. Using it for
development trades the whole signature model for one convenience. **A dev key is the better
primitive and it already works**: generate a per-developer keypair, add its public key to the
developer's LOCAL trust file under a publisher id of the form `dev.<handle>`, and sign dev
bundles with it. Signature enforcement stays **on** the entire time; the bundle is
distinguishable because its manifest names a different publisher.

Consequence worth stating plainly: **F8 needs almost no new trust code.** It needs ergonomics
(key generation, a local trust file, a `make dev-plugin` target) plus the banner in Decision 3.

### Decision 2 — production refusal is STRUCTURAL, not a mode

No dev-mode switch, no environment variable, no "is this prod?" heuristic — every one of those
is a thing a deploy can inherit or a detector can get wrong. Instead: **a production trust file
lists only the `latticenet` publisher** (already the documented rule for the operator's trust
policy). A dev-signed bundle therefore fails signature verification on any production server for
the ordinary reason — its publisher is not trusted there. Nothing to switch off, nothing to
forget, nothing to inherit.

`allow_unsigned_host_risk` stays **false everywhere, including dev**. If a future need seems to
require it, that is a signal the dev key path is broken, not that the flag should be used.

### Decision 3 — the banner must name the condition, not the mode

Since there is no "dev mode" to announce, the honest signal is: **any trusted publisher other
than `latticenet`**. When that holds the server logs it at startup (as now) **and** the
dashboard shows a persistent marker, so a screenshot of a dev-trusted node can never be mistaken
for production. This is the only part touching the dashboard — athena's area, a small task, and
it should not ride hephaestus's slice.

### Decision 4 — blast radius, stated rather than assumed

A leaked dev key signs bundles that load **only on servers whose trust file lists that key** —
in practice, that developer's own machine. Containment follows from the shape: keys are
**per-developer**, never shared, never committed, never added to CI, and never added to the
production trust file. A dev key is not a second publisher for the project; it is one
developer's local convenience.

### Decision 5 — allowed surface for the implementation slice (hephaestus)

- **In**: `tools/**` (key generation + a `make dev-plugin`-style target), plugin-repo docs, and
  a local example trust file that is `.gitignore`d.
- **Out**: `.github/workflows/**`; `cmd/pluginsign` behaviour; any production trust file; any
  change to `TrustPolicy` evaluation; the dashboard banner (athena's).
- **Forbidden**: committing any key material, or a default that adds a dev publisher to a trust
  file the server would use in production.

### Operator ruling (2026-07-28)

1. **Dev-key path: ACCEPTED.** Local development signs with a per-developer key and exercises
   the real signature path.
2. **Banner: ACCEPTED**, as a separate small task for athena — not blocking hephaestus's slice.

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
