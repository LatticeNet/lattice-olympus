---
task: TASK-0026
title: Give plugins a kv.delete host call
owner: unassigned
status: ready
repos: [lattice-sdk, lattice-server]
branches: []
last_touched_by: principal
depends_on: [TASK-0022]
blocked_by_ruling: —
needs_ack: no
created: 2026-08-07
---

## The gap

The plugin host surface has `kv.get` and `kv.put` and no delete. A plugin can
write a key and can overwrite it; it can never remove one.

That was tolerable while KV held a handful of scratch values. It stopped being
tolerable when Sub-Store began storing one generator script per file under its
own key: deleting a file can only write zero bytes over its script, so the key
survives its record. The cost is bounded — records are capped at 256, and the
tombstone is empty — but a tombstone is not a deletion, and the two differ the
moment anything enumerates the key space or accounts for it.

## Why it is cheap now

`Store.DeleteKV` already exists and, since TASK-0022, writes through to the
record-level bolt path. The host method is a thin wrapper over a call that is
already correct.

No new capability: `kv:write` is what a delete is. A plugin that may overwrite
a key to nothing may remove it.

## Scope

- In: `HostMethodKVDelete` in the SDK, its client method, the server handler
  gated on `kv:write`, and the key-scoping check that `kv.put` already applies
  so one plugin cannot delete another's keys.
- Out: any change to what Sub-Store stores. It should adopt the call once it
  exists, in its own wave.

## DoD

- [ ] `kv.delete` exists in the SDK and the server, gated on `kv:write`
- [ ] a plugin cannot delete a key outside its own prefix, proven by a test
- [ ] deleting a missing key is not an error
- [ ] finish letter

## Log (append-only, newest first)

- 2026-08-07: found while landing script files in Sub-Store, which tombstones
  instead. Filed rather than folded in, to keep that wave inside one repo.
