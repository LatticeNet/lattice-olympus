---
from: zeus
to: zeus
date: 2026-07-25T17:11Z
re: general
needs_reply: no
status: open
---

Instantiation record and the queue awaiting the human operator. Kept as a letter so it survives
context loss.

**Awaiting your decision (blocking others)**
1. **`plan/design-substore-embed.md` §4** — engine option for the Sub-Store embed.
   Recommendation: **Option C** (embed a JS interpreter in the Go artifact, keep fork-per-call,
   remote fetching stays a host capability). Option A (new resident "service" runner tier) is
   deferred, not forbidden. hephaestus's spike informs it; the ruling unblocks TASK-0002 Phase 2.
2. **§7 q2** — v1 feature scope: conversion + subscription management only, or also Sub-Store's
   scripting/operator pipeline (widens the JS surface a lot)?
3. **§7 q3** — may an upstream pin bump ride a normal task, or does re-signing gate it to a
   release window?

**Awaiting your hands (rules/03 — the agent will not do these)**
- **Land the instantiation on `main` before sharing the clone URL.** Olympus has no integration
  branch (AGENTS.md §4: this repo commits straight to `main`), so an instantiation parked on a
  side branch hands every arriving seat an empty mountain. One command:
  `gh pr merge 1 --repo LatticeNet/lattice-olympus --merge`. This is also the co-signature on
  changelog row #1. The agent does not push to `main` on its own.
- Create the `integration` branch in each code repo (from the repo's `alpha/v*` tip where one
  exists, else `main`), and set branch protection on `main`.
- Any tag push, image build, deploy, or `pluginsign` run.

**Live integrity issue found during setup** (memory: `gotcha-published-vs-acceptable-manifest`):
the published, signed sub-store manifest declares `secret:read|write`, which server `main`
rejects outright — that bundle cannot load on a `main` server. We have been signing artifacts
against branches. TASK-0006 turns this into a CI gate; TASK-0001 unblocks the merges.

**Two obligations this seat carries as orchestrator** (`pantheon/README.md §The gatekeeper's
obligation`): batch the rulings rather than answering one round-trip at a time, and split any
gating task that sits on a higher-share seat's critical path. TASK-0001 was already narrowed to
eight PRs for exactly this reason; the remainder is TASK-0007 and blocks nobody.

**State at instantiation**: ~22–23 open draft PRs across 9 repos, all unreviewed
(TASK-0001 + TASK-0007).
Deployed hub was last verified on the `alpha-0.2.2a1` image, `4 loaded, 0 rejected`. The
2026-07-15 deploy authorization was a one-time grant and is **void** under this protocol — any
new deploy needs a fresh explicit instruction.

— zeus
