---
task: TASK-0022
title: Decide whether kv and static belong in the bolt hot store or in state.json
owner: unassigned
status: draft
plan_ref: lattice/docs/designs/design-16-substore-native-subscription-platform.md §10.2
repos: [lattice-server]
branches: []
last_touched_by: principal
depends_on: []
blocked_by_ruling: kv-static-placement   # needs a decision before any code
needs_ack: yes
created: 2026-08-05
---

## The observation

`boltStateBuckets` (`internal/store/bolt_state.go:67`) includes buckets for both `kv` and
`static`. But `jsonPersistState()` (`internal/store/store.go:548-559`) excludes only
`Audit`, `Sessions`, `ProxyUsers`, `ProxyProfiles` and `ProxyUsage` from `state.json`.

So `kv` and `static` are written to **both** places: record-level into bolt, and in full into
`state.json` on every state write. Either the buckets are vestigial, or the exclusion list is
missing two entries. The tree does not say which, and guessing wrong in either direction is
expensive:

- if the buckets are vestigial and we start relying on them, reads and writes disagree after a
  restart;
- if the exclusion is an oversight and we leave it, every KV and static write keeps paying the
  full-rewrite cost, and `static` in particular is designed to hold file-sized content.

## What this task owes

A decision with a reason, then the small change that makes the code state it unambiguously —
either removing the unused buckets or adding the two domains to the exclusion list, with a
migration that moves existing entries rather than stranding them.

## Scope

- In: the decision record, the code change that follows from it, and a migration for data already
  written under the current behaviour.
- Out: any value size limit — that is TASK-0021, deliberately kept separable.

## DoD

- [ ] decision recorded with its rationale
- [ ] code makes the answer unambiguous; no domain is written to two authoritative places
- [ ] existing `kv` and `static` entries migrate rather than strand, proven by a test that starts
      from data written under the old behaviour
- [ ] finish letter

## Log (append-only, newest first)

- 2026-08-05: found while verifying constraints for design-16 and recorded there as §10.2. Left
  `draft` rather than `ready`: it needs a decision first, and design-16 deliberately depends on
  neither outcome.
