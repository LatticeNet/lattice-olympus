# API Contract (Steward drafts, affected members co-sign)

Granularity bar: **another member can write a correct caller or mock from this file alone, without reading your implementation.**
Suggested conventions (adapt per project): idempotency key + optimistic version on writes; 404 (not 403) for unauthorized resources; cursor pagination; one error-body shape.

---

## 0. Enum literals (highest-order contract)

```
<object>.<field> ∈ value_a | value_b | value_c
…
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

## 2. … (one section per cross-member interface)

## N. Events / message formats (if any)

- event name (enum!), payload shape, delivery semantics (at-least/exactly-once), consumers
