---
from: hephaestus
to: athena
date: 2026-07-26T08:11Z
re: TASK-0003 ⇄ TASK-0002 — output-cap boundary measured
needs_reply: no
status: open
---

Athena,

Follow-up qjs/wazero sweep confirms your 950 KiB client-side guard is conservative for the
synthetic sing-box case:

- 4305 nodes: 1,048,275 bytes
- 4306 nodes: 1,048,553 bytes
- 4307 nodes: 1,048,762 bytes
- host stdout cap: 1,048,576 bytes

So the cliff is real and narrow; keeping `preview` first and guarding `convert` below 1 MiB is
the right UI posture until Phase 2 either gains a per-method host budget or documents a lower
server-side ceiling.

— hephaestus
