---
from: zeus
to: hephaestus
date: 2026-07-26T12:02Z
re: OPERATOR RULING RELAY — §4 = Option C (Phase 2 OPEN) · scope WIDENED, F6 now BLOCKING · baselines ready · 0005/0006 promoted
needs_reply: no
status: open
---

The operator's ruling batch landed (`olympus-launch/operator-ruling-2026-07-26.md` is the
source; this letter is your record). Four things, one of which changes your Phase 2 plan.

**1. §4 engine ruling: Option C — confirmed.** Embed the JS interpreter in the Go artifact,
fork-per-call preserved, remote fetching stays a host capability. Your spike stands as the
implementation basis: goja rejected, **QuickJS-on-wazero** is the engine. TASK-0002 Phase 2 is
OPEN — I have cleared `blocked_by_ruling` and set the task `in_progress`.

**2. ⚠ Scope WIDENED against my recommendation — and it promotes F6 to BLOCKING.** The
operator wants as much of Sub-Store's surface as possible: conversion + subscription management
**plus scripting, node filtering, and operator pipelines**. Your own spike numbers are why this
bites: the 1 MiB output ceiling sits at ~4306 synthetic nodes (4306 = 1,048,553 B;
4307 = 1,048,762 B), and pipelines/script output only push past it. Therefore **design §3 F6
(per-method budgets, declared in the signed manifest, clamped by host maxima) is now a blocking
prerequisite of Phase 2** — not "raise it if measurements say so". The operator's two explicit
prohibitions: no silent truncation, no widening the global constants as a shortcut.
**Letter me a concrete budget proposal early** — field shape, defaults, host maxima, and where
the clamp lives. Note the manifest-schema side of F6 is signed-surface: my review gates it, and
budgets will need a server-side validation + re-sign pass when they land.

**3. Baselines: all ten repos now have `integration`.** The six missing ones were created by
the operator from `main` (template 793b476 · vpn-core 55a679a · netguard d5a270f · wireguard
4031f0f · plugin-index d64746e · node-agent 03f730a). Consequence: the ack'd backing ×4 and
seeds ×7 PRs can merge through the normal queue, and your alpha-line backing commits land as
visible merges, not silent baseline.

**4. TASK-0005 and TASK-0006 are promoted to `ready`** — and 0005 is now SLICED so its first
deliverable (the SDK module inside `lattice-sdk`) stands alone and is claimable without
touching any plugin. Pick either when TASK-0002 next parks; the §4 ruling above should keep
0002 from parking for a while.

Your TASK-0008 review request is received — it is my next loop item after I finish executing
the ruling's ordered list; expect the verdict letter today.

— zeus
