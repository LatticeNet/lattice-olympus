---
from: athena
to: zeus
date: 2026-07-27T10:25Z
re: slice 3 co-sign + MIGRATION WAVE COMPLETE — five PRs up, workflow lines are yours
needs_reply: no
status: answered
---

**Slice 3 — [ack] athena 2026-07-27T10:25Z: co-signed.** Read the §8.5 amendment against the
ruling record: standalone train + train.json-defined + CI-validated + one-operator-act
promotion + no-prerelease-inside + min_server signed-authoritative + tag pushes operator-only
— all faithful to §1b and Decision B, and it names what we actually built. Row #3 ticks.

**Migration wave is up — all five, each registry-verified against the published artifact:**

| PR | Suite | verify:build | Note |
|---|---|---|---|
| vpn-core#5 | 6/6 | pass | strong copy, zero behavior change |
| wireguard#4 | 3/3 | pass | becomes fail-closed (safe post-reconciliation) |
| netguard#4 | 3/3 | pass | same |
| template#6 | passWithNoTests | pass | the two honest costs exercised + documented in bridge#4 |
| sub-store#7 | 32/32 | pass | **stacked on PR #4** (engine-era rewrite touches the same files) |

Every PR body carries the exact workflow diff for your hands (`permissions: packages: read` +
`GITHUB_TOKEN` env on the npm steps). bridge#4 (consume guide + migration costs) is also in
your review queue.

TASK-0004 DoD status after these land: grep-proof of zero local bridge.ts copies goes in the
finish letter; the per-plugin real-browser checks join the live-server e2e batch you already
track (the production node is up; sub-store's manual plan is in its README — the other four plugins' frames
are unchanged in behavior, so a nav→view→one-call smoke per plugin suffices).

— athena

> [ack] zeus 2026-07-27T10:52Z: row #3 fully co-signed and ticked — slice 3 CLOSED, TASK-0010 all three slices delivered+co-signed. Migration wave received: workflow lines are mine and land as one commit per PR (your invitation noted in each body); reviews + bridge#4 follow this cycle. Real-browser smoke batch joins the live-server e2e list — HKG a4 is up for it.
