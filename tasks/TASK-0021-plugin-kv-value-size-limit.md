---
task: TASK-0021
title: Bound plugin KV value size before a plugin can grow state.json without limit
owner: unassigned
status: ready
plan_ref: lattice/docs/designs/design-16-substore-native-subscription-platform.md §10.1
repos: [lattice-server]
branches: []
last_touched_by: principal
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # a new host-enforced limit changes what existing plugins may write
created: 2026-08-05
---

## The defect

`Broker.KVPut` (`internal/plugin/broker.go:306`) checks the `kv:write` capability and the key
shape, then writes the value through unchanged. There is no value size limit anywhere on that
path.

Why that matters more than it looks: `kv` is **not** in the bolt hot-store exclusion list
(`internal/store/store.go:548-559`), so every KV entry is serialized into `state.json` — the single
file that is rewritten in full and fsynced on every state write. A plugin holding `kv:write` can
therefore make every unrelated state write in the server progressively slower, and eventually make
the store unwritable, without doing anything its capability forbids.

The blast radius is all persistence, not the offending plugin's own data.

## Scope

- In: a host-enforced maximum value size on the plugin KV write path, a clear error when exceeded
  (never a silent truncation), and an aggregate ceiling per plugin namespace if the per-value cap
  alone proves insufficient.
- In: a named test proving an over-limit write is refused and that the refusal names the limit.
- Out: changing where `kv` is persisted — that is TASK-0022's question, and the two must stay
  separable so neither blocks the other.
- Out: retroactively trimming any KV data that already exists.

## Notes

Choosing the limit is the real work. Too low breaks legitimate plugin use; too high leaves the
defect in place with extra steps. The limit needs a stated rationale tied to what `state.json`
can absorb, not a round number.

## DoD

- [ ] per-value limit enforced on the plugin KV write path, with the limit's rationale recorded
- [ ] over-limit write refused loudly, proven by a named test; no truncation path exists
- [ ] existing official plugins audited against the chosen limit before it lands
- [ ] finish letter

## Log (append-only, newest first)

- 2026-08-05: found while verifying constraints for design-16 and recorded there as §10.1. Filed
  separately on purpose: it threatens all persistence, so it should not ride a feature review.
