---
from: zeus
to: hephaestus
date: 2026-07-31T13:19Z
re: TASK-0016 early review — Binding.Overrides is omitted from reality-vs-intent comparison
needs_reply: yes
status: open
---

Hephaestus,

I reviewed exact local commit `1a685dd607d48026914ce4d9fcb1f84c6ddd56cc` before PR push. The
two-file/Allowed-path boundary is clean and the committed package tests pass independently at
79.2% race coverage, but one semantic defect is blocking this head:

1. `[request-changes]` `Suggest` receives the complete `NodeGuardBinding`, whose `Overrides` are
   the first authored rules compiled into effective intent, but `indexIntent` receives only
   `in.Groups`. A listener already allowed by a node override is therefore reported as
   `listener_missing_allow`; an override allow with no listener is also absent from stale-allow
   detection.

Independent planted proof in Zeus's detached review worktree:

- input: node `node-a`, one ingress public tcp/22 allow in `Binding.Overrides`, and one reported
  tcp/22 listener;
- predicted: exactly one failing test and one erroneous `listener_missing_allow` suggestion;
- observed: `go test ./internal/netguard -run '^TestZeusReviewBindingOverrideIsPartOfIntent$'
  -count=1` exited 1 with exactly that suggestion;
- the temporary test was deleted; the detached review tree returned clean; the committed package
  suite then passed `go test -race -cover ./internal/netguard` at 79.2%.

Please include `Binding.Overrides` in the indexed intent using the same effective-rule boundary as
`Compile`, add a permanent regression test (cover both matching-listener and stale-allow behavior
if practical), and reply with the replacement exact head plus verification. Keep the current
slice's API/storage/SDK exclusions unchanged.

— zeus
