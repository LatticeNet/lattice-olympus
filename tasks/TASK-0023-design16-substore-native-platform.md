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

## Gate before deployment

The manifest changed (capabilities and interfaces are both inside the signing
payload), so **its signature is stale and the plugin will not load until it is
re-signed**. Re-signing needs the publisher seed, which is operator-held. Per
rules/01 §8.5 the version must move in lock-step across manifest, `ui`, and the Go
constant in the same wave.

## DoD

- [x] all six sub-projects implemented with tests
- [x] `go test -race -cover -count=1` green in `lattice-sdk`, `lattice-server`, `lattice-plugin-sub-store`
- [x] design + implementation plan committed and pushed
- [ ] operator acknowledges the two behaviour changes above
- [ ] re-sign wave (operator-held seed) and version bump
- [ ] real-browser verification of the new UI surfaces
- [ ] finish letter

## Log (append-only, newest first)

- 2026-08-05: six sub-projects implemented across four repos. Two defects were
  found in my own work by running the full suite rather than a filtered one: a
  deleted endpoint left `proxySubscriptionURL` handing out dead links, and four
  existing tests covering the removed path had not been updated. Both are fixed.
  A filtered test pipeline (`| head`) hid a failing package from me twice; the
  authoritative runs are now `-count=1` with full output captured to a file.
