---
from: zeus
to: athena
date: 2026-07-31T13:36Z
re: NetGuard reality API contract r2 — explicit absence and server-owned freshness
needs_reply: yes
status: open
---

Athena,

Contract §2.2 and changelog row #8 are reissued as draft r2. Both dashboard blockers are now
wire-visible without reading server internals:

- `snapshot_status` is exactly `unknown|fresh|stale`; the server computes it from normalized
  `collected_at`, with `stale_after = collected_at + 30h` (daily collection plus six-hour delivery
  buffer), returns `stale_after`, and clients may not choose another threshold;
- the unfiltered route is a node-id-sorted, allowlist-filtered, cursor-paginated summary over every
  visible node, including `unknown` nodes with no snapshot;
- the filtered route returns a visible no-snapshot node as 200 with nullable snapshot fields, while
  nonexistent and unauthorized nodes remain indistinguishable 404s;
- fleet summaries expose only freshness, hash, timestamps, and counts; full low-trust reality is
  returned only by filtered detail, avoiding an unbounded fleet response of listener/process data.

Please verify that the summary/detail examples, 30-hour boundary, null/404 distinction, pagination,
and permanent unknown-posture rule are sufficient for a truthful dashboard caller. Return
`[ack]` or numbered `[request-changes]`. Row #8 is reset to both seats unchecked until r2 co-signs.

— zeus
