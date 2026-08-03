---
task: TASK-0007
title: Review sweep of the remaining draft-PR backlog (nobody is blocked on this)
owner: zeus
status: done
plan_ref: plan/dev-history-2026.md §"Open threads" item 1
repos: [lattice-dashboard, lattice-plugin-template, lattice-plugin-vpn-core, lattice-plugin-netguard, lattice-plugin-wireguard, lattice-plugin-sub-store, lattice-plugin-index, lattice-server]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: no
created: 2026-07-25
---

## Goal

Every remaining open draft PR gets a recorded verdict, so the backlog becomes a merge queue
instead of a pile. Explicitly **off** the critical path — TASK-0001 carries that; this one is
what zeus works between rulings.

## Scope & boundaries

- In: the feature backlog — dashboard #3 (lines), #4 (sidebar), #5 (passkeys), #6 (inventory);
  the plugin re-sign PRs (vpn-core / netguard / wireguard / sub-store / template `#2`,
  template `#3` execute-reference); `plugin-index#1` and the `chore/gitignore-signing-seeds`
  family (batch these — one letter covers the set); anything TASK-0001 defers.
- Out: the eight critical-path PRs (TASK-0001); fixing findings; merging; deploys.
- **Allowed paths**: `lattice-olympus/tasks/**` · `messages/**` · `status/zeus.md` · `memory/**`
- **Forbidden**: same as TASK-0001 — no pushes to reviewed branches, no un-drafting before acks.

## Notes

- Re-inventory first (`gh pr list --state open` per repo): the 2026-07-25 survey counted ~22–23
  open drafts across nine repos, all drafts, but TASK-0001 removes eight from this scope.
- **Already landed elsewhere**: `lattice#1/#2` and the sing-box-fork PRs are MERGED; server
  #15–#19 were closed as drafts while their commits shipped via `alpha/v0.2.2`. For those,
  verify the commits got review-equivalent scrutiny and close **with a comment linking the
  landing commit** (rules/01 §8.5) rather than reviewing a dead PR.
- Chore PRs can be verdict-batched; feature PRs cannot.
- This task is interruptible by design: park it whenever TASK-0001 or a ruling batch needs the
  seat, and hand it back per `prompts/handoff.md` if another seat picks it up.

## DoD

- [x] every remaining open draft PR has a recorded verdict (PR comment + Olympus letter) —
      seeds ×7 [ack] batch · backing ×4 [ack] · template#3 [ack]; letter 20260726-0815Z
- [x] closed-but-landed PRs annotated with their landing commits — server#3/#4 (a0308cb),
      dashboard#5/#4 (0115575), #3 (5c3d82f), sub-store#2 (integration tip 3c3571f);
      dashboard#6 verified properly MERGED
- [x] `memory/notes/map-draft-pr-backlog` updated with the full picture
- [x] merge-blocking findings: NONE — all open PRs merge-ready, gated only on the integrator
      pass (integration-branch creation ×6, operator queue)
- [x] finish letter sent (broadcast 20260726-0815Z)

## Log (append-only, newest first)

- 2026-08-03T12:36Z: live GitHub/open-PR audit found ten Drafts. TASK-0017 server#27 is the
  only active feature. Server#9's sole `.gitignore` blob exactly equals current integration and
  landed as `748bb05a4ef599e99e12dcf561e362f3f9d16378`; Zeus posted that proof and closed the stale
  Draft. The other six signing-seed PRs are **not landed**: each integration `.gitignore` lacks
  the reviewed eleven-line seed block, so they remain open and become TASK-0018 rather than being
  falsely closed. Template#3 is not patch-equivalent to integration and remains open for a
  separate semantic carry decision. Sub-store#5 remains the intentionally open engine spike
  recorded by TASK-0002. No branch was retargeted, merged, or edited during this audit.

- 2026-07-26 08:05Z: claimed by zeus agent after TASK-0001 finished. Re-inventory: 17 open
  drafts — dashboard #3/#4/#5 (#6 closed, verify landing); 5× feat/declare-service-backing
  (template/vpn-core/netguard/wireguard/sub-store #2); 7× chore/gitignore-signing-seeds
  (those five + plugin-index#1 + server#9); template#3 execute-reference; server#3
  node-inventory + server#4 passkeys. Plan: containment check → seeds batch (one letter) →
  backing five (individual verdicts, shared frame) → template#3 → dashboard features →
  server#3/#4.
- 2026-07-25: split out of TASK-0001 so the critical path stays small.
