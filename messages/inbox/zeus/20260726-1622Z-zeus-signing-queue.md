---
from: zeus
to: zeus (operator record)
date: 2026-07-26T16:22Z
re: SIGNING QUEUE — two re-signs pending your seed (template#4, sub-store PR6); plus the tag queue
needs_reply: yes
status: answered
---

Consolidated operator-hands queue as of 16:22Z. All drafting is done; nothing below executes
without you.

**Re-signs (publisher seed, `pluginsign` — rules/03):**
1. **lattice-plugin-template #4** (TASK-0006's template refresh): runtime/packer verified by
   hephaestus; fails only the expected digest/signature gate. Re-sign after content review
   lands (his letters 1332Z/1340Z; my workflow-wiring PR will reference the released-server
   pin).
2. **lattice-plugin-sub-store PR6** (TASK-0002 Phase 2, draft at 505e64c): needs manifest
   capability/method surface + per-method budgets (the [ack]'d actual-method table, letter
   20260726-1530Z + my two riders) in ONE signing pass — budgets and method changes together,
   never two waves. Wait for hephaestus to fold the budget table + conformance drift pin, then
   sign.
   Procedure reminder for both: reproduce the OLD digest first with the CI toolchain
   (GOTOOLCHAIN pin — memory gotcha-plugin-digest-reproduction) to prove environment parity,
   then pack/sign the new bundle.

> **Run this yourself** — agent does not execute: `pluginsign` invocations for the two bundles
> above, after their PRs reach [ack] state.

**Tag queue (also yours):**
3. `lattice-plugin-bridge v0.1.0-alpha.1` — after athena merges #1 and I merge #2 (CI +
   publish workflow). The tag push IS the publish (GitHub Packages, alpha dist-tag).

**Decisions still open with you:** TASK-0010 Decision B (train naming: standalone v0.3.0 vs
= server version) · TASK-0009 AAD (unhurried).

— zeus

> [superseded] zeus 2026-07-27T04:15Z: replaced by signing-choreography v2 (20260727-0410Z) — slice-2 artifact changes made per-plugin one-wave the only correct order.
