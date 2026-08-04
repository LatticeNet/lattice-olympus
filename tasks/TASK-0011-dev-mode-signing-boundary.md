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

## Principal ruling on the last DoD box (2026-08-04T13:50Z)

Box 3 as written asks for something a production server must never be able to show. Production
trusts exactly one publisher, so the production evidence is **absence**, and the box is split:

- **production half — proven by absence** at the `alpha-0.2.2a5` deploy: no non-official startup
  warning in the server log, no banner in the dashboard;
- **positive half — proven by the merged tests** (`TestPluginTrust*` server-side, the dashboard's
  `trustBannerModel` suite), not by a screenshot of a node we would have to deliberately mis-trust
  in order to produce one.

Manufacturing a dev-trusted node to photograph it was never worth the risk it creates.

## DoD

- [x] the five decisions above recorded, with rationale, and co-signed where they touch contract
- [x] fail-closed production refusal proven by a named test (a server without dev trust
      explicitly enabled rejects a dev-signed bundle) — TASK-0013, merged
- [x] banner visible in server logs AND dashboard while dev trust is on — split per the ruling
      above: positive half proven by merged tests, production half by recorded absence
- [x] hephaestus's implementation slice scoped in writing before it starts — TASK-0013 allowed
      paths recorded before the branch existed
- [ ] finish letter

## Log (append-only, newest first)

- 2026-07-31T11:21Z: TASK-0013 r2 reviewed at server `a559b14` and template `3173de7` in
  Zeus-owned detached worktrees. The mutable tool pin, caller-controlled recursive delete,
  force/mode/input-alias paths, and preflight collision cases are closed or materially improved;
  exact server SHA resolution, new regression tests, template CI, targeted race/cover, vet, full
  server tests, and template Go race tests passed. R2 remains `[request-changes]`: command-line
  path overrides can put seed/trust outside the only ignored directory, and `DEV_BUNDLE=manifest.json`
  reaches pluginpack's truncating/removing output sink (2 HIGH); `writeNewLocalFile` can leave a
  partial final path on post-create write/close/mode failure (1 MEDIUM). Fixes and named adverse
  tests requested; no merge is authorized.

- 2026-07-31T11:04Z: early Zeus gate review of TASK-0013 heads server `18fe3a0` and template
  `384ca69` returned `[request-changes]` (2 HIGH, 2 MEDIUM). HIGH: the Makefile executes mutable
  remote `@integration` code with the seed path, and an overrideable `DEV_BUNDLE_ROOT` feeds
  `rm -rf` (`make -n DEV_BUNDLE_ROOT=system-go dev-bundle` targets tracked source). MEDIUM:
  `O_TRUNC` preserves an existing permissive seed mode and sign output can alias seed/artifact;
  keygen writes seed before proving the trust destination, so failure can leave a mismatched pair.
  Positive evidence: allowed-path audit, named refusal test, tool tests, full `go test ./...`,
  targeted race, vet, gopls, gofmt, and diff checks all passed in Zeus-owned detached review
  worktrees; no operational key material was generated. Fixes and regression tests requested in
  the r1 letter; no merge is authorized.

- 2026-07-31T10:52Z: server#24 passed hephaestus's independent security review and merged to
  server `integration@7e57b85`; post-merge `go test -race ./internal/server -run
  TestPluginTrust -count=1` and `go test ./cmd/lattice-server ./internal/server -count=1`
  passed. This closes only the server surface: TASK-0012's real dev-trusted browser/screenshot
  proof remains open. Hephaestus claimed the isolated ergonomics slice as TASK-0013 on exact
  branches `feat/hephaestus-task0013-dev-plugin-loop`, based at server `7e57b85` and template
  `cdede0f`; its allowed paths and no-workflow/no-key/no-trust-semantics boundaries are recorded,
  and Zeus review remains required before either merge.

- 2026-07-31T10:20Z: current-state audit confirmed the policy is ratified but the ergonomics
  slice never started. Server#24 (trust endpoint + startup warning, head `a84c3fe`) remains open;
  dashboard#11 is merged at integration `04c4046`; the screenshot/browser proof still requires a
  real dev-trusted environment and is not claimed. Batched hephaestus a security review of
  server#24 plus the implementation handoff: claim the next available task number, stay inside
  Decision 5's allowed surface, and keep workflows/pluginsign/trust evaluation out of scope.

- 2026-07-28T10:25Z: claimed by zeus. Drafting the policy record; hephaestus's implementation
  slice stays closed until it exists (his condition, correctly stated).

- 2026-07-28: created by zeus after hephaestus declined to self-assign F8 across the
  signing/trust boundary (his letter 20260728-0344Z). Split accepted verbatim: policy first
  (mine), ergonomics second (his), never the reverse.
