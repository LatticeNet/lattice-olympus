---
task: TASK-0001
title: Critical-path review — the plugin-host PRs that unblock every other lane
owner: zeus
status: in_progress
plan_ref: plan/dev-history-2026.md §"Open threads" item 1
repos: [lattice-server, lattice-sdk, lattice-dashboard]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: no
created: 2026-07-25
---

## Goal

Clear the **eight** PRs that everything else waits on, and nothing more. Deliberately small:
`hephaestus` holds ~60% of the share and `zeus` ~10%, so a wide gating task here starves the
forge (`pantheon/README.md §The gatekeeper's obligation`). The rest of the backlog is TASK-0007
and blocks nobody.

## Scope & boundaries

- In, in this order:
  1. `lattice-server#7` fix/plugin-gateway-hardening — narrows `/api/plugins/invoke`; every
     later PR sits on this path.
  2. `lattice-server#8` feat/plugin-service-backing → `#10` feat/require-declared-backing
     (stacked; #10 is a two-sided breaking change — check the staged deployment order).
  3. `lattice-server#11` feat/plugin-secret-storage — without it the published sub-store
     manifest cannot load at all ([[gotcha-published-vs-acceptable-manifest]]).
  4. `lattice-sdk#6` feat/approval-operation-binding → `lattice-server#12`
     feat/plugin-operation-execute (typed columns; sdk first per release order).
  5. `lattice-dashboard#9` fix/plugin-frame-reload-boundary and the `feat/bridge-host-origin`
     work — the shipped bridge/host mismatch (design §3 F2).
- Out: everything else (TASK-0007); fixing findings (own tasks per domain); merging (merges
  follow rules/01 §4–5 after acks); any deploy or tag push.
- **Allowed paths**: `lattice-olympus/tasks/**` · `messages/**` · `status/zeus.md` · `memory/**`
- **Forbidden**: pushing commits to any reviewed branch; taking a PR out of draft before its
  acks are on record; force-pushing anything.

## Notes

- Review order above is the merge order: it honors the release order (sdk → server → dashboard)
  and the stacking (#8 → plugin re-signs → #10).
- **Verdicts are per rules/02 §3.5**: exactly one of `[ack]` / `[request-changes]` /
  `[review-unavailable]` per round, in a letter, with evidence.
- Ruling batching: any architecture question this surfaces goes into the same batch as the
  design §4 ruling rather than a separate round-trip.
- Deliver **incrementally** — letter each verdict as it lands. hephaestus's TASK-0002 Phase 2
  needs items 1–4; do not hold them behind item 5.

## DoD

- [ ] each of the eight PRs has a recorded verdict (PR comment + Olympus letter)
- [ ] merge-order letter sent (broadcast) naming stacking and the two-sided deploy constraint
- [ ] merge-blocking findings each have a follow-up TASK (draft is fine)
- [ ] `memory/notes/map-draft-pr-backlog` records the inventory and verdicts
- [ ] hephaestus told explicitly when items 1–4 are ack'd — that message unblocks TASK-0002 Phase 2
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-26 07:48Z: items 1–4 DONE — six [ack] verdicts on record (letter
  20260726-0746Z-zeus-task0001-items1-4-verdicts, evidence: server tip 86422a1 full -race
  green 397.6s/69.8%, sdk tip green). KEY FINDING: 7 of 8 items already contained in
  integration (cut from alpha tips); only bridge-host-origin outstanding, and its tree ==
  dashboard main tip. Integration-behind-main divergence found in sdk + dashboard + sub-store
  → integrator ruling drafted for operator batch. Findings for follow-up tasks: RPC
  Call-path probe leak (Low, #8); envelope no-AAD relocation (decision needed, #11).
  Item 5 in progress: dashboard suite running; #9 diff reviewed clean.

- 2026-07-26: claimed by zeus agent (operator confirmed in-session). Review-only task — no code
  branch; writes stay in Olympus. Order: server#7 → #8→#10 → #11 → sdk#6→server#12 → dashboard#9
  + bridge-host-origin. Verdicts letter out incrementally; explicit unblock letter to hephaestus
  after item 4.
- 2026-07-25: narrowed from the full backlog sweep to the eight critical-path PRs; the
  remainder became TASK-0007 so the highest-share seat is never queued behind the gate.
