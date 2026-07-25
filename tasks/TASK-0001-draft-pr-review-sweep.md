---
task: TASK-0001
title: Review sweep of the outstanding draft-PR backlog (~20 PRs across 9 repos)
owner: zeus
status: ready
plan_ref: plan/dev-history-2026.md §"Open threads" item 1
repos: [lattice-sdk, lattice-server, lattice-dashboard, lattice-plugin-template, lattice-plugin-vpn-core, lattice-plugin-netguard, lattice-plugin-wireguard, lattice-plugin-sub-store, lattice-plugin-index, lattice, sing-box]
branches: []
depends_on: []
needs_ack: no
created: 2026-07-25
---

## Goal

Every outstanding draft PR in the LatticeNet org (plus lr00rl/sing-box#1) receives a recorded
review verdict, so the backlog stops being a pile and becomes a merge queue. This is the
standing review lane: verdicts follow rules/02 §3.5 (numbered rounds, explicit
`[ack]` / `[request-changes]` / `[review-unavailable]`), one letter per repo batch.

## Scope & boundaries

- In: enumerate all open draft PRs (`gh pr list` per repo); review each diff for correctness,
  security semantics, test adequacy, doc sync; record verdicts as PR review comments AND Olympus
  letters; propose a merge order honoring the release order (sdk → server / dashboard /
  node-agent → docs site → plugins → plugin-index) and stacked-PR deps (e.g. server#8 → plugin
  re-signs → server#10); file follow-up tasks for merge-blocking findings.
- Out: fixing the findings (separate tasks, owned per domain); merging anything (merges follow
  rules/01 §4–5 after acks); any deploy.
- **Allowed paths** (this is a review task — writes land in Olympus only):
  - lattice-olympus/tasks/** · lattice-olympus/messages/** · lattice-olympus/status/zeus.md
  - lattice-olympus/memory/** (durable findings)
- **Forbidden**: pushing commits to any reviewed branch; flipping any PR out of draft before
  its acks are on record; force-pushing anything.

## Notes

- Open-draft counts at creation (2026-07-25 survey): server 6 (#7 #8 #9 #10 #11 #12) ·
  dashboard 4 (#3 #4 #5 #9) · sdk 1 (#6) · template 3 (#1 #2 #3) · vpn-core 2 · sub-store 2 ·
  netguard 2 · wireguard 2 · plugin-index 1 — ~22–23 total; re-inventory as step 1.
- Already landed elsewhere (verify, then close-with-comment rather than review): lattice#1/#2
  and all sing-box-fork PRs are MERGED; server #15–#19 were **closed as drafts** but their
  commits shipped via `alpha/v0.2.2` — spot-check those commits got review-equivalent scrutiny.
- Review priority: security-bearing server PRs (#7/#8/#10/#11/#12) first — they gate the
  plugin train and the Sub-Store work (TASK-0002 stacks on the sidecar-capable host).
- Cheap wins (gitignore chores) can be verdict-batched in one letter.

## DoD

- [ ] PR inventory table (repo · # · title · verdict · blocking findings) committed under
      `memory/notes/` as `map-draft-pr-backlog`
- [ ] every open draft PR has a recorded verdict (PR comment + Olympus letter)
- [ ] merge-order proposal letter sent (broadcast) honoring release order + stacking
- [ ] merge-blocking findings each have a follow-up TASK (draft is fine)
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-25: created at Olympus instantiation; first batch `ready`.
