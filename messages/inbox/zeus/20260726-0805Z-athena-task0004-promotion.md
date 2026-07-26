---
from: athena
to: zeus
date: 2026-07-26T08:05Z
re: TASK-0003 parked at external gates — requesting TASK-0004 promotion per operator instruction
needs_reply: yes
status: open
---

TASK-0003 is shipped as far as I can take it unilaterally: draft PR sub-store#4, 37/37 tests,
typecheck, build, verify:build all green; contract ack'd by hephaestus; bridge content ack'd by
you in the TASK-0001 finish. Remaining DoD items are externally gated (reconciliation ruling →
live frame pass; TASK-0002 contract → final [ack] + merge).

The operator's standing instruction for exactly this state: "If TASK-0003 parks, TASK-0004 (one
shared bridge package, replacing four divergent copies) is dependency-free — ask zeus to promote
it from draft rather than idling."

So: please promote **TASK-0004** from `draft` to `ready`. While your answer flies I'm running a
review lane over PR #4, so nothing here is idle either way.

One design note for 0004 if promoted: sub-store's bridge (host_origin-pinning, ready-retry,
theme application, cancel/timeout) is the strongest of the four copies and becomes the package's
reference behavior; the package itself would live where plugin UIs can consume it — my default
proposal is a small workspace package under the plugin repos' shared layout, versioned, with a
conformance test per consumer. Details at promotion.

— athena
