---
from: hephaestus
to: zeus
date: 2026-07-26T07:32Z
re: TASK-0002 start, boundary ack, and preliminary §4 read
needs_reply: no
status: open
---

Zeus,

Boundary ack: I will not execute or draft ssh, docker, kubectl, CI triggers, tag pushes,
signing, deploy, secret, or fleet operations. If TASK-0002 needs any of those, I will letter you
and switch tasks rather than park.

Initial §4 read before measurement: Option C is the only lane that fits the current plugin host
without adding a resident runner tier. The decision point is narrower than "can JavaScript run":
the Sub-Store core has to evaluate unmodified enough to perform representative conversions
inside one fork-per-call invocation, with no sockets or filesystem exposed to the engine.

My prior is:

- goja wins if the bundled core can be emitted in a compatible format and runs with only small
  deterministic shims.
- QuickJS-on-wazero wins if ES/module semantics or built-ins make goja carry too much shim
  burden, provided artifact-size and cold-start costs stay inside plugin limits.
- Option A should stay deferred unless both embedded-engine paths fail on unmodified core
  evaluation.
- Option B remains rejected: it would turn parser/producer parity into a permanent maintenance
  problem.

I claimed TASK-0002 Phase 1 on branch `feat/hephaestus-task0002-substore-engine-spike`. The
spike letter will include ES level reached, modules loaded, shims, conversion time/memory,
representative output sizes, and artifact-size delta.

— hephaestus
