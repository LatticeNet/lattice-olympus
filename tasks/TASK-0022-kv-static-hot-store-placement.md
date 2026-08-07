---
task: TASK-0022
title: Decide whether kv and static belong in the bolt hot store or in state.json
owner: principal
status: in-progress
plan_ref: lattice/docs/designs/design-16-substore-native-subscription-platform.md §10.2
repos: [lattice-server]
branches: [lattice-server:feat/principal-kv-static-placement]
last_touched_by: principal
depends_on: []
blocked_by_ruling: —   # ruled 2026-08-07, see Ruling
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


## Ruling (2026-08-07, principal)

**The exclusion list was the oversight. KV and Static move to the record-level
bolt path.**

The observation as drafted understated it. Re-read against the current tree, the
state is not "written to both places" — it is worse and more specific:

- `Store.PutKV` / `PutStatic` mutate memory and call `Save()`, which encrypts and
  rewrites **the whole JSON state** and fsyncs it. That is the authoritative copy.
- `BoltStateStore.PutKV` / `PutStatic` exist and are correct, and **had no
  caller**. The buckets were populated only by the whole-state `ImportState`.
- `ExportState` reads both buckets into the returned state, and
  `mergeRuntimeBoltHotState` then **discarded them** — it merged only the five
  domains it knew about.

So the buckets were not vestigial and not functional: half-wired in both
directions. Guessing "vestigial" and deleting them would have been wrong.

The reason to move rather than to delete is already written down in the tree, by
whoever excluded the two domains that came after this task was filed:

> Snapshots are provider payloads: potentially megabytes each, rewritten on every
> refresh. Keeping them in the JSON state would make every unrelated write pay
> for them.

`static` is designed to hold file-sized content — that argument applies verbatim,
and the forcing case arrived: Sub-Store file generator scripts are 25–59 KB each,
and one operator's real set is 529 KB. Putting those in the JSON state means
every unrelated state write in the server re-encrypts and rewrites half a
megabyte of JavaScript.

### What the ruling required beyond the one-line exclusion

Three things had to land together, or the store disagrees with itself:

1. **write-through** — `PutKV`/`DeleteKV`/`PutStatic` go to bolt when the hot
   store is enabled, following the `UpsertProxyUser` pattern exactly;
2. **unconditional merge** — `dst.KV = hot.KV`, not the `len(hot.X) > 0` fallback
   the other domains use. Those still exist in both places, so falling back is
   right for them. Here an empty bolt means empty, and treating it as permission
   to keep the JSON copy would resurrect every deleted entry;
3. **one-time migration** — entries written under the old behaviour are pushed
   across on first open, guarded by a `_meta` flag.

The flag is not defensive padding. Without it the migration re-runs on every
open, and because the JSON file keeps its stale copy until the next write, the
second run pushes back everything deleted since the first. A test written before
the flag existed caught exactly that: a deleted KV entry came back after a
reopen.

The stale JSON copy is also dropped explicitly on the migrating open, because
otherwise the file keeps carrying the bytes this change exists to remove.

### Also fixed here, because the files feature needs it

`Static` had **no delete at all** — objects could only be written. Tolerable for
a handful of hand-uploaded assets; not tolerable once something writes an object
per record, where replacing a file's script would leave every previous version
behind forever. `Store.DeleteStatic` and `BoltStateStore.DeleteStatic` are added.

## Scope

- In: the decision record, the code change that follows from it, and a migration for data already
  written under the current behaviour.
- Out: any value size limit — that is TASK-0021, deliberately kept separable.

## DoD

- [x] decision recorded with its rationale
- [x] code makes the answer unambiguous; no domain is written to two authoritative places
- [x] existing `kv` and `static` entries migrate rather than strand, proven by a test that starts
      from data written under the old behaviour
- [ ] finish letter

## Log (append-only, newest first)

- 2026-08-07: ruled and implemented on `feat/principal-kv-static-placement`. The forcing case was
  Sub-Store file scripts (529 KB in one operator's real set) needing somewhere that is not the
  full-rewrite path. Scope grew by one item the ruling names: `static` had no delete.

- 2026-08-05: found while verifying constraints for design-16 and recorded there as §10.2. Left
  `draft` rather than `ready`: it needs a decision first, and design-16 deliberately depends on
  neither outcome.
