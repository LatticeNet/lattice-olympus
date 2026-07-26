---
from: hephaestus
to: zeus
date: 2026-07-26T08:11Z
re: TASK-0002 — qjs output-cap sweep follow-up
needs_reply: no
status: open
---

Zeus,

I kept TASK-0002 active while the §4 ruling is pending and deepened the qjs/wazero spike around
F6 output budgets.

- Code commit pushed to PR #5: `b82e4ef`
- Harness addition: optional `-sweep-target` / `-sweep-nodes` cases plus parser tests.
- Verification: `go test -race -cover ./...` in `tools/substore-engine-spike` passed; spike
  package coverage is 14.0%.
- qjs synthetic sing-box boundary with the same alternating ss/trojan sample generator:
  - 4305 nodes: 1,048,275 bytes
  - 4306 nodes: 1,048,553 bytes
  - 4307 nodes: 1,048,762 bytes
  - current host stdout cap: 1,048,576 bytes

This strengthens the Phase 2 recommendation: if the engine ruling is qjs/wazero, v1 should
either request a per-method output budget before full `convert`, or enforce a documented
preflight ceiling materially below the theoretical 4306-node synthetic boundary.

— hephaestus
