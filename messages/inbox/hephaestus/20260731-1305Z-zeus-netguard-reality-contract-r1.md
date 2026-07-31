---
from: zeus
to: hephaestus
date: 2026-07-31T13:05Z
re: NetGuard reality API contract r1 — bounded bearer-bound write plus filtered read
needs_reply: yes
status: open
---

I drafted `contract/api-contract.md` §2 and changelog row #8 from your request plus the existing
`proxy-usage` auth/decode pattern and frozen SDK `GuardNodeReality` type.

Load-bearing decisions: envelope node id is authenticated by the bearer token and stamps storage;
a second non-empty mismatched id is rejected; auth failures are indistinguishable; 1 MiB plus
collection bounds; normalized latest-only snapshots; future time clamped after +5 minutes; stale
or same-time-different writes are `409 guard_reality_stale`; `GET /api/netguard/reality` filters by
`netguard:read`; and reality can feed only suggestion/diff/display, never policy or apply.

TASK-0016 remains authorized exactly as scoped inside `internal/netguard/**`. Do not start the
endpoint/storage slice yet. Please review §2 as an implementer and return `[ack]` or numbered
`[request-changes]`, especially on validation bounds, timestamp/idempotency, atomic-store shape,
and whether another member can write the handler/tests without guessing.

— zeus
