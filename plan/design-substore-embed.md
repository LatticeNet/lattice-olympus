# Design · Fully embedding Sub-Store, and the plugin-framework review behind it

Status: **proposal — awaiting the arbiter's ruling on the engine option (§4)**
Author: zeus · Date: 2026-07-25 · Supersedes nothing; amends by new numbered file (rules/04)
Evidence: every file:line below was read on `main` at survey time; the load-bearing five were
re-verified by the author personally.

---

## 1. Why the "Node sidecar + reverse proxy" plan does not apply here

The pre-Olympus embedding sketch assumed a generic Go service that could spawn
`node sub-store.min.js`, keep it resident on `127.0.0.1:3000`, and reverse-proxy `/substore/*`
to it. That plan is sound for a plain Go web app. It is **incompatible with the Lattice plugin
host as built**, for four independently fatal reasons:

1. **Fork-per-call, not a daemon.** `lattice-server/internal/plugin/system_runner.go:21-27`
   states the contract verbatim: *"Each invocation is a FRESH process whose lifetime is exactly
   one action … there is no long-running daemon to heartbeat or reap."* The only plugin exec
   site in the whole server repo is `system_runner.go:340`, bounded by a 10s deadline, 3s
   SIGTERM→SIGKILL grace, 1 MiB output cap, 64 host calls, and a 5-failure circuit breaker
   (`:29-35`, `:344-346`, `:621-640`). There is no supervisor, no restart policy, no port
   allocation, and no reverse proxy to a plugin-owned listener anywhere in the codebase.
2. **Plugins have no HTTP surface at all.** The wire protocol is `stdio-json-v1`: one
   `{action,payload}` JSON in on stdin (closed immediately, `:407-413`), NDJSON out on stdout,
   host RPCs as `{"host_call":…}` lines answered on **fd 3** (`:328-337`, `:431`,
   `LATTICE_HOST_RESPONSE_FD=3` at `:342`). Actions: `describe|health|plan|call`. Proxying
   HTTP into a plugin is not a thing the host can do.
3. **The runtime entrypoint is regex-locked to a native binary.**
   `internal/plugin/manifest_v2.go:108` requires every `runtime.entrypoints` value to be a safe
   bundle path starting with `bin/` — the host execs it directly. There is no interpreter
   invocation path, and `node` is not on the fixed PATH the child receives (`childEnv()`
   `system_runner.go:644-658`).
4. **Shipping Node inside the bundle exceeds the loader bounds.** `bundle_v2.go:22-25` caps a
   bundle at 32 MiB **per file**, 2048 files, depth 16. A Node 22 linux-x64 binary is ~100 MB —
   over the per-file limit by 3×, before `node_modules` is considered. (Sub-Store's own backend
   bundle, a single esbuild output of a few MB, fits comfortably — that asymmetry is the whole
   opportunity, see §4.)

The frontend half of the old plan is likewise blocked, but softly: the plugin document is
served under `default-src 'none'; … connect-src 'none'`
(`internal/server/server_plugin_assets.go:112-127`), so a packed Sub-Store SPA **cannot fetch
its own API** — `?api=<origin>` has nothing to talk to. All plugin→host traffic must go through
the postMessage bridge, whose only verb is `lattice.plugin.call` → `POST /api/plugins/call`,
filtered against the signed manifest's declared methods
(`lattice-dashboard/src/views/platform/pluginBridgeModel.ts:120-121`, `:209`, `:279`).

**Conclusion:** embedding Sub-Store is not "one missing feature". Either the engine changes
shape to fit the host, or the host grows a new runner tier. §4 decides which.

---

## 2. Framework review — what is strong

Read the strengths before proposing changes; this host has real engineering in it.

- **Supply chain**: ed25519 signature over a versioned payload prefix
  (`plugin.go:203`, `:265-270`), trust policy holds public keys only (`:58-60`, `:244-255`),
  private seed never leaves the operator/release CI. `bundle.digest_sha256` must equal a
  byte-reproducible packer output — sub-store's CI packs twice and byte-compares
  (`lattice-plugin-sub-store/.github/workflows/ci.yml:79-88`), built `-trimpath
  -buildvcs=false` on a pinned toolchain.
- **Load & exec hygiene**: digest re-verified at `Start()` (TOCTOU-aware,
  `system_runner.go:109`), `0700` staged copy (`:132-142`), symlink rejection (`:209`),
  no shell, env allowlist + fixed PATH, `Setpgid` + process-group kill, output caps, breaker.
- **Bounded extraction**: 32 MiB/file, 2048 files, 240-byte paths, depth 16 (`bundle_v2.go:22-25`).
- **Browser isolation**: `sandbox="allow-scripts"` without `allow-same-origin` (opaque origin),
  `referrerpolicy="no-referrer"`, rotating 32-byte fragment nonce with an 8s handshake timeout
  (`PluginFrameHost.vue:191-202`, `pluginBridgeModel.ts:54-58`, `:68`, `:139-156`), CSP as above,
  and a manifest-declared method allowlist enforced host-side.
- **Authorization**: per-method `effect` + `scopes` checked server-side with every decision
  audited (`server_plugin_invoke.go:207`, `:217/:397`, `:361`); host-risk capabilities are
  system-plugin-only (`plugin.go:153-156`); unknown capability is a hard reject (`:145`).
- **Operator-target binding**: private-network HTTP needs `http:operator-target` **plus**
  per-method `operator_target_fields`, extracted from the authenticated payload and bound to a
  single origin/path for exactly one invocation (`server_plugin_invoke.go:226/:338` →
  `system_runner.go:285` → `broker.go:191`, `:215`). This is the sharpest control in the system.
- **Inter-plugin RPC**: directed `host_access.rpc` edges materialized only while active and
  revoked on disable (`server_plugin_grants.go:8-23`, `rpc.go:110`, `:182`).

## 3. Framework review — findings to fix (ranked)

**F1 · Published-vs-acceptable integrity gap (High, live).** `lattice-plugin-sub-store`'s
**signed, released** manifest declares `secret:read` / `secret:write`, but neither capability
exists on server `main` — absent from `capabilityRisk` (`plugin.go:63-102`) and from
`dispatchHostCall` (`system_runner.go:504-619`). `ValidateManifest` rejects unknown capabilities
outright (`:145`), so the currently published sub-store bundle **cannot load on a `main`
server**. Same class: `interfaces[].backing` is signed data that `main` does not parse
(`contributions.go:97-105` has no `Backing` field), and `substore:read|admin` scopes live only
on an unmerged branch. *We are publishing signed artifacts against a server that does not
exist yet.* Fix = land the queued server work (TASK-0001 → merges), and add a CI gate that
validates every published manifest against the **released** server's validator, not the branch's.

**F2 · Bridge-client fragmentation (High).** Three hand-rolled `bridge.ts` copies have already
diverged: template 360L reads only `lattice_nonce` (`:355`); sub-store/vpn-core 247L require
`host_origin` and throw without it (`:191-204`); wireguard carries an older copy (`:183`).
Meanwhile the dashboard emits only `lattice_nonce` (`pluginBridgeModel.ts:95`) — the fix sits
unmerged on `feat/bridge-host-origin`. So the *shipped* combination is broken for two plugins,
and the weakest copy silently sets the security bar. Spec §8 ("Plugin UI Toolkit") is unbuilt.
Fix = one versioned, published bridge package consumed by every plugin; forbid local copies.

**F3 · `/api/plugins/invoke` bypasses per-method scope (Medium; fix queued).** Gated only by
`plugin:admin` (`server.go:817`) while `/call` enforces per-method RBAC. Hardening PR
(server#7) narrows it to a describe/health allowlist — merge it before anything else grows on
top of that path.

**F4 · Stale reference implementation (Medium).** `lattice-plugin-template/system-go/main.go`
is 117L with no host calls, no secrets, no fd-3 reader, and a manifest without `backing` or
`operator_target_fields`; sub-store is 779L and is the *de facto* reference. New plugins
started from the template inherit a pre-hardening shape. Fix = template becomes the richest,
not the thinnest, and CI diffs its manifest schema against the current validator.

**F5 · No plugin SDK (Medium, flexibility).** `lattice-sdk` ships only `model/` + `proto/`;
every manifest/capability/plan/secret type and the entire stdio runtime loop live inside
`lattice-server/internal/plugin`, unimportable. Each plugin re-implements framing, host-call
scanning, and error mapping by hand. Fix = extract a `lattice-plugin-sdk` Go module (runtime
loop + typed host client + manifest types) and the TS bridge package from F2; that pair is the
single highest-leverage investment for "灵活的开发能力".

**F6 · Global, not per-method, resource budgets (Medium, blocks §4).** 10s invoke / 1 MiB
output are package constants (`system_runner.go:29-35`). A subscription conversion over a large
provider list can exceed both. Fix = per-method budgets declared in the manifest (signed),
clamped by host maxima.

**F7 · Known, already-recorded holes.** `rbac.Allows` empty-nodeID hole (why no official plugin
declares node-scoped interfaces — [[gotcha-rbac-empty-nodeid]]); secret envelope without AAD
(ciphertext relocatable between records); asset subresources served credentialless with
`ACAO: *` where the path digest is the only authorization (rate-limited, acceptable given the
opaque origin, but note it).

**F8 · No local development loop (Low, flexibility).** Nothing documents how to run a plugin
unsigned against a dev server. Every iteration currently implies a signing round-trip through
the one human who holds the seed. Fix = a dev-mode trust policy (dev-only key, loud banner,
refused when `LATTICE_PUBLIC_URL` looks production) + `make dev-plugin`.

---

## 4. The engine decision (three options; recommendation and rationale)

Requirement restated: **the Sub-Store backend capability and its UI ship inside the Lattice
plugin, with no separately-installed Sub-Store service.**

### Option A — new "service" runner tier (Tier-3 resident subprocess)
Host grows a supervisor: long-lived child, health probes, restart/backoff, loopback port
allocation, and a gateway route that proxies `/api/plugins/service/<id>/*` into it. Plugin
ships `node` + the Sub-Store bundle.
- **Cost**: a second exec model in the trust base (today: exactly one exec site, easy to audit);
  bundle limits must rise ~4× or Node must be a host prerequisite (breaking the self-contained
  premise); resident processes need cgroups/memory caps, log rotation, crash-loop policy; the
  CSP/bridge model needs a proxied-fetch escape hatch. Roughly a quarter of the current plugin
  host's security surface, added again.
- **Verdict**: highest fidelity to upstream Sub-Store, **highest risk**, and it contradicts the
  ADR-001 "small trust base" doctrine that the 2026-07-14 review re-affirmed.

### Option B — reimplement the conversion engine in Go
- **Cost**: Sub-Store's value *is* its long tail of parsers/producers across proxy formats;
  reimplementation is a permanent maintenance tax and will silently diverge from upstream.
- **Verdict**: rejected for scope, not for architecture.

### Option C — **embed the JS engine, keep fork-per-call** ★ recommended
Sub-Store's backend is Express **plus** a pure core (`ProxyUtils`: parsers, producers, filters,
operators). The core is string→string; it needs neither Express, nor sockets, nor fs. So:
- The Go plugin binary embeds a JavaScript interpreter (evaluate `goja` — pure Go, no cgo —
  against QuickJS-on-`wazero` for ES2020+ coverage; the choice is an implementation spike, and
  the criterion is *Sub-Store core evaluates unmodified*).
- The signed bundle carries `lib/substore-core.js` (a few MB — well inside the 32 MiB/file
  limit) built from a pinned upstream Sub-Store commit by the plugin's own CI, so the JS is
  **covered by the same digest and signature as the binary**.
- Each `call` action: instantiate engine → evaluate core → run one conversion → return JSON.
  Fork-per-call is preserved; no supervisor, no ports, no proxy, no new trust surface.
- Fetching remote subscriptions stays a **host** capability (`http.do` / `http.operator.do`),
  never the JS engine's — so SSRF policy, operator-target binding, and audit all keep working
  exactly as today. The engine sees strings, not sockets. This is strictly *safer* than upstream
  Sub-Store, which has no auth at all.
- Storage: subscription/config records via `kv.get|kv.put` (on `main` today); credentials via
  `secret.*` once F1's merges land.
- Scheduled sync (Sub-Store's cron) maps onto the existing approval/task path, not onto a
  resident timer.

**Recommendation: Option C**, with Option A explicitly deferred — not forbidden. If a future
plugin genuinely needs a resident non-Go runtime, Tier-3 should be designed on its own merits,
with its own threat model, rather than smuggled in as a Sub-Store implementation detail.

**What C costs honestly**: not 100% upstream parity on day one (Express-only behaviors, some
Node-API-dependent producers need shims); an engine-compatibility spike is a real risk item; per-
method budgets (F6) are a prerequisite for large conversions; and the upstream-pin/update story
(`lib/substore-core.js` bumps = artifact change = digest change = re-sign) must be routine.

---

## 5. Frontend plan (independent of §4; buildable now)

- Pack a Lattice-native Vue UI at `ui/` in the same signed bundle — **not** upstream Sub-Store's
  SPA. Reason: the upstream SPA's entire data layer is `fetch` to its own API, which
  `connect-src 'none'` forbids; retrofitting it means rewriting that layer anyway, and we would
  inherit an unpinned upstream UI inside our signature. Rewriting the *screens we need* against
  the bridge is comparable work with a fraction of the surface.
- The UI speaks only `lattice.plugin.call`; every method it calls must be manifest-declared.
- Nav: `manifest.ui.nav` under section `extensions`, icons from the dashboard's lucide allowlist,
  scope-filtered (`usePluginContributions.ts:200-217`).
- Reuse the **shared bridge package** from F2 rather than copying `bridge.ts` a fourth time.
- Verification: real-browser check is mandatory (operator's standing law); `verify:build` must
  keep rejecting inline script/style and any external URL
  (`ui/scripts/scan-build.mjs:15-20`, `:29-40`).

## 6. Sequencing

1. **TASK-0001** (zeus) — review sweep; unblocks the merges F1/F2/F3 depend on.
2. **Prerequisite merges** — secrets + `backing` + operations (server), substore scopes,
   dashboard `feat/bridge-host-origin`. Without these, sub-store cannot load on `main` at all.
3. **TASK-0002** (hephaestus) — engine spike → decision confirmed → Sub-Store core embedded,
   methods implemented, conformance green. Gated on zeus's §4 ruling.
4. **TASK-0003** (athena) — plugin UI against the bridge, real-browser verified.
5. Follow-ups, each its own task: shared bridge package + plugin SDK (F2/F5), template refresh
   (F4), per-method budgets (F6), dev-mode signing loop (F8).

## 7. Open questions for the arbiter

1. §4 ruling: C (recommended), or A if unmodified-upstream fidelity is worth a new runner tier?
2. Feature scope for v1: conversion + subscription management only, or also Sub-Store's
   scripting/operator pipeline (the latter widens the JS surface substantially)?
3. Is an upstream pin bump allowed to ride a normal task, or does re-signing gate it to a
   release window?
