---
task: TASK-0023
title: Design 16 — Sub-Store as a native subscription platform (all six sub-projects)
owner: principal
status: in_progress
plan_ref: lattice/docs/designs/design-16-substore-native-subscription-platform.md
repos: [lattice, lattice-sdk, lattice-server, lattice-plugin-sub-store]
branches: [docs/principal-design16-substore-native, docs/principal-design16-plan, feat/principal-design16-share-model, feat/principal-design16-subscription-shares, feat/principal-design16-subscription-source]
last_touched_by: principal
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # new host capability + a behaviour change to an existing endpoint
created: 2026-08-05
---

## Why this exists

The operator's goal moved from "integrate with a standalone Sub-Store" to **shut
it down**. That reverses `plan/design-substore-embed.md §7` open question 2, which
had scoped v1 to conversion only. Acceptance is one sentence: *the operator can
stop the standalone instance and every client that subscribed to it keeps
working.*

## What shipped

All six sub-projects are implemented. Code is green; **nothing is deployable yet**
— see the signing gate below.

| # | Sub-project | State |
|---|---|---|
| 1 | Subscription store + public distribution | implemented |
| 2 | Remote fetch + snapshot fallback | implemented |
| 3 | Processing pipeline completion | implemented |
| 4 | Migration from an existing Sub-Store | implemented |
| 5 | Operations surface (backup/restore, settings) | implemented |
| 6 | Artifact publishing | implemented |

The plugin's `…/subscription` service now declares eleven methods: `fetch`,
`render`, `operators`, `preview`, `list`, `migrate`, `export`, `import`,
`get_settings`, `save_settings`, `publish`. Two capabilities were added:
`http:egress` (provider fetch, broker-guarded) and `subscription:serve`.

## The load-bearing decisions

**The core keeps the entire public surface.** Route, token lookup, slug
comparison, rate limit, audit, headers and output cache are all core-owned; the
plugin answers one question — given a subscription id, a format and a bounded
client class, produce content. A general `http:serve` capability was rejected for
handing token checking and rate limiting to plugin code, which is the shape the
plugin-boundary review already turned down.

**A subscription response is never an empty body with HTTP 200.** A proxy client
that receives one deletes every node it had. This is enforced in three places
independently — the plugin refuses to produce empty content, the core refuses to
serve it, and the cache refuses to store it — because each layer alone would be a
single point of silent destruction.

**The last good snapshot is durable, not cached.** Its home took **three**
attempts and both wrong answers are recorded in the design rather than quietly
replaced: bolt is unreachable from a plugin, and the plugin's runtime working
directory is deleted by `SystemRunner.Stop` by design. A plugin has no durable
storage that is not the state file, so the core holds the snapshot as an opaque
blob and the plugin stays stateless.

**Refresh is lazy, not scheduled.** A fork-per-call plugin cannot schedule itself,
so a timer would have to be a new core mechanism, and clients already poll on
their own cadence. Upstream syncs on a timer; this deliberately does not.

## Findings that changed the work

- **Upstream silently ignores an unknown operator type.** Probed against the real
  engine: `"Definitely Not An Operator"` converted happily and changed nothing.
  A typo therefore produced a pipeline that reported success and did nothing. The
  operator catalog exists to refuse that, and its contents are extracted from the
  bundled engine by a test rather than hand-maintained, so a pin bump that renames
  an operator breaks the build instead of drifting.
- **The pipeline was never the gap.** `process()` already ran upstream's whole
  operator chain, so sub-project 3 was discoverability and validation, not
  capability.
- **`worker:route` is not an HTTP runtime.** It is `{{path}}` string interpolation
  behind an authenticated endpoint, so it could not have served subscriptions.

## Behaviour change requiring operator acknowledgement

`/sub/<token>` is **removed**; the only shape is `/sub/<slug>/<token>`. Affordable
because the deployment had zero proxy users, profiles and inbounds.

Two consequences an operator must know:

1. **A subscription that renders zero endpoints now returns non-2xx, not an empty
   200.** Existing tests asserted the old behaviour for an unapplied profile and a
   disabled user; both were changed with the reason recorded inline. A client
   receiving an empty success wipes its configuration, and "the profile is not
   applied yet" must not arrive at the client as "you have no nodes".
2. **Rotating a proxy user's sub token no longer changes public access.** The
   share holds the public credential. The rotate response now returns the share's
   URL and `rotates_public_access: false` rather than a URL the rotation does not
   control.

## Gate before deployment — CLEARED 2026-08-05

The manifest changed (capabilities and interfaces are both inside the signing
payload), so its signature was stale and the plugin would not load until it was
re-signed. Signed and shipped as **0.5.0-alpha.1**.

Three things the wave forced, each a real gate rather than a formality:

1. **Every interface method must declare `scopes`.** `validateCapabilities`
   asserts; it does not warn. Read methods take `substore:read`, write methods
   `substore:admin`, matching the existing `import`/`engine` interfaces.
   `migrate` and `publish` additionally declare `operator_target_fields`,
   because both hand the host an operator-designated URL.
2. **The release order is enforced by the validator, not by convention.** The
   manifest check pinned to the a4 commit rejected `subscription:serve` as an
   unknown capability. The server has to be released first; only then can the
   plugin naming that capability be signed.
3. **Sign with the released server's `pluginsign`, not a local checkout.** Local
   `main` predates a6 and its `plugin.Manifest` does not know the `backing`
   field, so it would have computed a signing payload the deployed verifier does
   not agree with. Signing used
   `pluginsign@v0.2.2-0.20260805145356-4e41f1410201`.

## DoD

- [x] all six sub-projects implemented with tests
- [x] `go test -race -cover -count=1` green in `lattice-sdk`, `lattice-server`, `lattice-plugin-sub-store`
- [x] design + implementation plan committed and pushed
- [x] operator acknowledges the two behaviour changes above (answered by ruling
      the empty-render case into a silent masquerade rather than an error)
- [x] re-sign wave and version bump — 0.5.0-alpha.1, lock-step across manifest,
      `ui/package.json` and the Go constant
- [x] released, index advertises it, deployed and verified in production
- [x] a user interface exists at all (added after the fact — see below)
- [ ] real-browser verification of the new UI surfaces
- [ ] finish letter

## Verification evidence (2026-08-05)

Bundle digest `ca82b389d0e53c991409bfa4a838539097f453c749f13caed33f3806352983f1`
agreed across four independent paths: the local packer, an independent
`shasum`, CI's rebuild on linux/amd64, and the artifact downloaded back from the
published release.

Loading was proven before production saw it: the signed bundle was run through
the **released a6 image's own loader** in a throwaway container under a
fail-closed trust policy (`allow_unsigned_host_risk` absent ⇒ false, and
`subscription:serve` is host-risk, so an invalid signature would have been
rejected) — `1 loaded, 0 rejected`. Production then reported `4 loaded, 0
rejected`, and the extraction path is keyed by both version and digest
(`0.5.0-alpha.1/ca82b389…/bin/linux-arm64/plugin`), which is what proves the
running bytes are the signed ones rather than a retained older bundle.

Probe resistance confirmed against the live public route: unknown share paths
return 404 with a zero-byte body and **no `X-Request-Id`**, so a prober cannot
distinguish "this share does not exist" from "this path is not served here", and
cannot tell whether the request reached the application at all.

A false-negative worth recording: the first throwaway container reported
`0 loaded, 1 rejected`, which looked like a signature failure. It was not — the
harness had omitted `LATTICE_PLUGIN_BUNDLE_CACHE_DIR`, which production sets. A
verification harness that does not mirror the deployed configuration produces
verdicts about itself, not about the artifact.

## Log (append-only, newest first)

- 2026-08-06: **the feature had no user interface, and no way to create
  anything.** The operator opened the plugin page and still saw only Import,
  Pipelines and Convert. Two separate gaps, both mine:

  1. Eleven subscription methods shipped signed and deployed with **no caller**.
     The design decomposed the work into six *backend* sub-projects and never
     scoped a UI, so the feature was complete by its own definition and unusable
     by the operator's. My report of "six sub-projects implemented" described
     the method surface and did not say this.
  2. The interface had **no create path**. `list` existed; `get`, `save` and
     `delete` did not. `saveSubscription`/`deleteSubscription` were reachable
     only from `migrateFromSubStore` and `importBackup`, so a subscription could
     enter the store by migration or backup restore and by nothing else.

  Closed by adding the three methods (with `origin` preserved server-side so a
  caller cannot forge migration provenance), a Subscriptions tab and a Settings
  tab in the plugin, and a subscription-shares view in the **dashboard** —
  shares are core-owned and the plugin frame runs with `connect-src 'none'`, so
  it cannot reach `/api/subscription-shares` and should not be able to.
  Released as sub-store `0.6.0-alpha.1` and server image `alpha-0.2.2a7`
  (same server tree as a6; only `dashboard.ref` moves).

  Worth keeping: a backend can pass every test it has, be signed, be deployed,
  and still deliver nothing. "Implemented" needs to mean reachable by the person
  who asked for it.

- 2026-08-05: signed, released and **deployed**. `v0.5.0-alpha.1` published with
  bundle + manifest assets; the index alpha channel advertises it, with digest,
  capabilities and signature copied from the released manifest rather than
  retyped. `subscription:serve` had to join the index validator's capability
  vocabulary — that check asserts rather than warns, so the index cannot
  advertise a capability it does not know. Twice in this wave a piped `EXIT=$?`
  read the exit code of `tail` instead of the command, once reporting a failing
  index validation as green; authoritative runs capture output to a file and
  read the real code.

- 2026-08-05: six sub-projects implemented across four repos. Two defects were
  found in my own work by running the full suite rather than a filtered one: a
  deleted endpoint left `proxySubscriptionURL` handing out dead links, and four
  existing tests covering the removed path had not been updated. Both are fixed.
  A filtered test pipeline (`| head`) hid a failing package from me twice; the
  authoritative runs are now `-count=1` with full output captured to a file.
