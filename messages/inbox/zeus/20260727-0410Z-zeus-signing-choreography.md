---
from: zeus
to: zeus (operator record)
date: 2026-07-27T04:10Z
re: SIGNING CHOREOGRAPHY v2 — one re-sign per plugin; supersedes the 16:22Z queue
needs_reply: yes
status: open
---

Everything content-side is now [ack]'d. The 16:22Z queue is superseded: TASK-0005 slice 2
added five more artifact changes, so per-plugin one-wave choreography is the only order that
avoids double re-signs. **Merge first, sign once at each repo's combined `integration` tip.**
The per-PR digests hephaestus recorded become stale on merge — recompute at the tip (that is
expected, not an error; GOTOOLCHAIN parity check first as always).

| Plugin | Content to merge (all [ack]'d) | Then ONE re-sign at tip |
|---|---|---|
| template | #4 (F4 refresh) + #5 (SDK migration) | ✔ |
| vpn-core | #4 (SDK migration) | ✔ |
| wireguard | #3 (SDK migration) | ✔ |
| netguard | #3 (SDK migration) | ✔ |
| sub-store | PR6 (engine+budgets) with SDK migration FOLDED IN (my [ack fold] on the PR; hephaestus pushes e78b6c0's content onto PR6, then merges) | ✔ |

Integration will run digest-red between merge and your signing pass — expected and visible,
not silent; the CI gate is doing its job.

**Also yours, unchanged:**
1. **Bridge tag** `v0.1.0-alpha.1` — recommendation: after bridge#3 merges (it is [ack]'d;
   athena merges), so alpha.1 ships the complete API. Tag push = first publish.
2. **Decision B** (train naming) — still open; PR6's `min_server` deliberately waits to ride
   whichever floor you name, in its signing pass if you answer before you sign, else the next.
3. **TASK-0009 AAD** — unhurried.

> **Run this yourself** — agent does not execute: the five `pluginsign` passes at the merged
> tips, and the bridge tag push.

— zeus

> [update] zeus 2026-07-27T04:18Z: item 4 for the queue — the NEXT SERVER ALPHA TAG (from integration, slot claimed in shared-resources on your word) unblocks three things at once: TASK-0006 CI wiring needs a RELEASED server carrying the validator to pin; TASK-0003 e2e needs a live integration-line server; the train About-check needs an injected version to compare. One tag, three gates.
