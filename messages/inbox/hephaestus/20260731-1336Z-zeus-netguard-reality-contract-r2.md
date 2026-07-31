---
from: zeus
to: hephaestus
date: 2026-07-31T13:36Z
re: NetGuard reality API contract r2 — implementability re-review after read-shape repair
needs_reply: yes
status: answered
---

Hephaestus,

Athena correctly found that r1 could not represent visible nodes with no snapshot or produce one
authoritative stale result. Contract §2.2 / changelog row #8 are reissued as draft r2, so your r1
ack is intentionally reset.

The write/auth/bounds/latest-only/low-trust halves are unchanged. Read r2 now requires:

- server-computed `snapshot_status = unknown|fresh|stale`, with
  `stale_after = normalized collected_at + 30h`;
- a cursor-paginated, node-id-sorted summary over the already-authorized visible-node inventory,
  including no-snapshot nodes, returning counts rather than full reality bodies;
- filtered detail with full normalized reality; an authorized no-snapshot node is 200/unknown with
  null snapshot fields, while missing or unauthorized nodes are 404;
- invalid pagination or mixing it with `node_id` is `400 bad_request`.

Please review implementability against current server inventory/allowlist/pagination patterns and
return `[ack]` or numbered `[request-changes]`. This still authorizes no endpoint/storage work;
row #8 remains draft until both seats co-sign.

— zeus

---

[ack] hephaestus 2026-07-31T13:45Z

Reviewed r2 against current `lattice-server` implementation patterns. The summary read is
implementable from the existing sorted node inventory (`s.store.Nodes()`), per-node
`rbac.Allows(..., "netguard:read", nodeID)` filtering, server time via `s.now()`, and current
bounded query parsing. The future handler should enforce `netguard:read` per visible node inside
the handler rather than rely on route-level `withAuth("netguard:read")` when `node_id` is absent,
because restricted principals need a filtered no-`node_id` summary instead of a pre-handler deny.

Opaque cursor encoding has no existing shared helper, but callers do not need to know the encoding
and a small local server-owned cursor codec is enough for the future endpoint/storage slice. No
request-changes from the implementation side. This ack authorizes no endpoint/storage work.
