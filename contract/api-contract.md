# API Contract (Steward drafts, affected members co-sign)

Granularity bar: **another member can write a correct caller or mock from this file alone, without reading your implementation.**
Suggested conventions (adapt per project): idempotency key + optimistic version on writes; 404 (not 403) for unauthorized resources; cursor pagination; one error-body shape.

---

## 0. Enum literals (highest-order contract)

```
NetGuardRealitySummary.snapshot_status ∈ unknown | fresh | stale
NetGuardRealityDetail.snapshot_status ∈ unknown | fresh | stale
```

## 1. Plugin UI bridge protocol v1 (owner: athena; consumers: every plugin UI; host: dashboard; steward: zeus)

Canonical implementation: `@latticenet/plugin-bridge` (`lattice-plugin-bridge`, from PR #1).
The dashboard host side lives in `lattice-dashboard` `pluginBridgeModel.ts`. Changing anything
below is a contract change (this file + changelog + co-sign), not a package refactor.

- **Channel**: iframe URL fragment `#lattice_nonce=<16–128 chars>&host_origin=<origin>`.
  `host_origin` must reparse to exactly itself (`new URL(v).origin === v`) and be http(s) —
  everything else, and absence of either param, fails closed (no wildcard, no fallback).
- **Inbound guard (plugin side), in order**: not disposed → `event.source === window.parent`
  → payload is an object → `nonce` matches → `event.origin` equals the pinned `host_origin`
  exactly. Outbound always `postMessage(msg, host_origin)` — never `"*"`.
- **Messages plugin→host** (`type` enum): `lattice.plugin.ready {nonce}` ·
  `lattice.plugin.call {nonce,id,service,method,payload}` · `lattice.plugin.cancel {nonce,id}`
  · `lattice.plugin.resize {nonce,height}`.
- **Messages host→plugin**: `lattice.host.init {nonce,version:"1",pluginId,pluginVersion,
  pluginRoute,locale,colorScheme,designTokens,interfaces[]}` ·
  `lattice.host.theme {nonce,colorScheme,designTokens}` ·
  `lattice.host.result {nonce,id,result}` · `lattice.host.error {nonce,id?,message,code?}` ·
  `lattice.host.dispose {nonce}`.
- **Invariants**: init requires `version === "1"`, the expected `pluginId`, and a declared
  view route; `designTokens` filtered to the fixed 11-entry CSS-variable allowlist (both init
  and theme paths); a `result`/`error` id without a pending entry is a no-op; `dispose`
  rejects every pending call; ready-handshake retries 500 ms × 16 by default.
- **Error semantics**: default call timeout 15 s (a `cancel` is posted upward); typed
  `BridgeHandshakeError/RemoteError/CancelledError/TimeoutError/DisposedError`;
  `lattice.host.error` without `id` rejects init and all pending calls; `code` on
  `BridgeRemoteError` carries the wire code verbatim.
- **Idempotency / concurrency**: call ids are unique per client instance (`idPrefix` +
  counter); duplicate/unknown ids are no-ops; every reload of the frame is a new trust
  boundary (host re-keys the element and mints a fresh nonce — dashboard#9 semantics).

## 2. NetGuard node-reality ingestion v1 (DRAFT; not in force until changelog row #8 is co-signed)

Owners/consumers: node-agent writes; server authenticates, normalizes, and stores; dashboard and
NetGuard surfaces read. Canonical payload type is SDK `model.GuardNodeReality`. The entire surface
is **low-trust input for suggestions, diffs, drift badges, and display only**. It must never mutate
policy, enqueue an apply task, approve a plan, or bypass the existing reviewed apply path.

### 2.1 Agent write

- **Route**: `POST /api/agent/guard-reality`; every other method returns `405 method_not_allowed`.
- **Credentials**: the HTTP Authorization header using the bearer-token scheme only. No token in
  JSON, query, or logs.
- **Request**:

  ```json
  {"node_id":"node-a","reality":{"node_id":"node-a","listeners":[],"interfaces":[],"managed_sha":"","foreign_tables":[],"nft_version":"","collected_at":"2026-07-31T13:00:00Z"}}
  ```

  `node_id` is required for the existing per-node token lookup. Authentication proves that the
  bearer token belongs to that node; the server then overwrites the stored reality's node id with
  the authenticated envelope id. `reality.node_id` may be empty for forward compatibility, but a
  non-empty unequal value is a `400 bad_request`. Unknown, disabled, source-denied, or wrong-token
  nodes all return the same `401 invalid_node_token` so the route does not enumerate nodes.
- **JSON/body semantics**: agent-forward-compatible unknown fields are ignored; malformed JSON,
  trailing JSON values, or a body over 1 MiB return generic `400 bad_request`. Before persistence:
  at most 4096 listeners, 256 interfaces, 64 addresses per interface, and 512 foreign-table names;
  protocol is `tcp|udp`; ports are `1..65535`; addresses must parse as an IP or prefix; SHA fields
  are empty or 64 lowercase hex characters; strings are trimmed printable UTF-8 and capped at 256
  bytes (interface names at 64). Any violation rejects the whole report; no partial snapshot.
- **Time**: `collected_at` is required and normalized to UTC. Values no more than five minutes in
  the future are retained; later values are clamped to server receipt time and the response says
  so. A normalized time older than the stored snapshot returns `409 guard_reality_stale`. Equal
  time + equal normalized content is idempotent `200`; equal time + different content is the same
  `409`. Server receipt time is stored separately and never taken from the node.
- **Persistence**: one latest normalized snapshot per node, atomically replaced only after all
  validation. Raw request bytes and bearer credentials are never persisted. Report acceptance is
  audited as `netguard.reality.report` with node id and counts, not listener/process/address data.
- **Success**:

  ```json
  {"ok":true,"node_id":"node-a","collected_at":"2026-07-31T13:00:00Z","received_at":"2026-07-31T13:00:01Z","collected_at_clamped":false}
  ```

### 2.2 Operator/dashboard read

- **Route and visibility**: `GET /api/netguard/reality` behind `netguard:read`. With
  `?node_id=<id>` it returns one node detail. Without `node_id`, it returns a node-id-sorted summary
  page over the principal's visible node inventory, including visible nodes that have never
  reported a snapshot. Principal server-allowlist filtering happens before pagination. Summary
  pagination uses opaque `cursor` plus `limit` (default 100, maximum 500); `node_id` is mutually
  exclusive with `cursor`/`limit`.
- **Server-authoritative freshness**: `snapshot_status` is exactly `unknown|fresh|stale`.
  `unknown` means no stored snapshot. For a snapshot, the server sets
  `stale_after = normalized collected_at + 30 hours` (daily collection plus a six-hour delivery
  buffer); it returns `fresh` before that instant and `stale` at or after it. The server computes
  the status at response time and returns `stale_after`; clients must not substitute their own
  threshold. `received_at` remains separately visible but is not the freshness clock.
- **Unfiltered summary response**:

  ```json
  {"nodes":[{"node_id":"node-a","snapshot_status":"fresh","collected_at":"2026-07-31T13:00:00Z","received_at":"2026-07-31T13:00:01Z","stale_after":"2026-08-01T19:00:00Z","managed_sha":"","listener_count":2,"interface_count":3,"foreign_table_count":1},{"node_id":"node-b","snapshot_status":"unknown"}],"next_cursor":"opaque"}
  ```

  Unknown summaries omit snapshot-derived timestamps, hash, and counts. Full listeners,
  interfaces, process/address data, and foreign-table names are never returned by the summary
  list. `next_cursor` is omitted on the final page.
- **Filtered detail response**:

  ```json
  {"node":{"node_id":"node-a","snapshot_status":"fresh","reality":<GuardNodeReality>,"received_at":"2026-07-31T13:00:01Z","stale_after":"2026-08-01T19:00:00Z"}}
  ```

  A visible node with no snapshot returns `200` with
  `{"node":{"node_id":"node-b","snapshot_status":"unknown","reality":null,"received_at":null,"stale_after":null}}`.
  A nonexistent or unauthorized filtered node returns `404 not_found`, so the route does not
  enumerate hidden nodes.
- Both read shapes expose normalized fields only and no agent token, source address, raw request,
  or collector stderr. Consumers must label foreign tables as unmanaged and render both `unknown`
  and `stale` as unknown posture, never as proof that the node matches desired policy.

### 2.3 Stable errors and concurrency

- `400 bad_request`: invalid envelope/payload, node-id mismatch, bounds/grammar failure, missing
  collection time, malformed/trailing/oversize JSON, invalid cursor/limit, or mixing `node_id`
  with pagination parameters.
- `401 invalid_node_token`: every agent authentication failure.
- `404 not_found`: filtered read missing or unauthorized.
- `409 guard_reality_stale`: older report, or same timestamp with different normalized content.
- `500 internal_error`: atomic persistence failed; the prior snapshot remains intact.
- Concurrent reports serialize per stored node record under the same timestamp rule. There is no
  merge of listeners/interfaces across reports and no last-writer-wins exception for stale input.

Changing a route, literal error code, bound, timestamp rule, low-trust restriction, or response
shape above is a contract change requiring a new co-signed row.

## N. Events / message formats (if any)

- event name (enum!), payload shape, delivery semantics (at-least/exactly-once), consumers
