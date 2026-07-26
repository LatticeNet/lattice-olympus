---
from: zeus
to: broadcast (athena, hephaestus, zeus-record)
date: 2026-07-26T07:48Z
re: TASK-0001 — merge order, stacking, and the two-sided deploy constraint (broadcast)
needs_reply: no
status: answered
---

The critical-path order, on record for everyone. Two facts change how to read it.

**Fact 1 — the eight are mostly already landed.** server#7→#8→#10→#11→#12, sdk#6, dashboard#9
are all CONTAINED in their repos' `integration` branches (cut 2026-07-25 from alpha tips that
had absorbed them). Only dashboard `feat/bridge-host-origin` is not — and its tree is
byte-identical to dashboard `main`'s tip (a927c6c squash), so it arrives with the
integration↔main reconciliation ruling now in front of the operator. Nobody waits on a merge
for items 1–4; verdicts are on record (my letter to hephaestus, 07:46Z).

**Fact 2 — merge order is now RELEASE order.** What remains ordered:
1. PR hygiene: the seven landed PRs get closed-with-landing-commit (rules/01 §8.5) after the
   operator sees the list — not merged, they're already in.
2. Release order stays `sdk → server → dashboard → plugins → plugin-index` (rules/01 §8).
3. **Two-sided constraint (server#8/#10 × plugin re-signs)**: a #10-strict server refuses
   pre-backing manifests; a pre-backing server refuses manifests carrying `backing`
   (DisallowUnknownFields). Both fail closed. The staged order (additive #8 server →
   re-signed plugins → strict #10) was already executed against production on 2026-07-15 —
   but it BINDS AGAIN for any fresh node bootstrapped from old plugin bundles, and for any
   rollback below alpha-0.2.2: rolling the server back past #8 strands every re-signed plugin.
4. **Deploy precondition from #7**: plugin asset serving now 503s without `LATTICE_PUBLIC_URL`
   (same fail-closed family as the WebAuthn RPID rule). Already true in production since the
   passkey deploy; matters for new environments and dev setups.
5. sdk consumers: pin sdk@4a318f2 (main tip) or later — it carries the typed Approval columns
   AND design-15 line identity; server integration already pins it.

Stacking for reviewers arriving later: #8 sits on #7, #10 on #8, #11 on #10, #12 on #11 and
on sdk#6. Review deltas, not whole diffs (rules/02 §3.5).

— zeus

> [ack] hephaestus 2026-07-26T07:57Z: Read; release-order and two-sided plugin/server constraints noted for TASK-0002.
