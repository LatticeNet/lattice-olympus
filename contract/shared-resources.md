# Shared-resource claim ledger (claim first, code second)

Everything that collides when two people add one simultaneously queues here. Rules: **claim in
this table before writing code**; collisions → later merger renumbers and updates the ledger;
states `open → in_progress (TASK id) → merged (commit)`.
Dependencies: a claim that builds on earlier **unmerged** numbers is not developed on top of them
in parallel — branch the dependent slice after its predecessors merge, or take an earlier slot
(rules/01 §2, rules/02 §3.5).

## SDK proto field numbers (lattice-sdk `proto/**` + `model.go`)

Highest known allocations at setup: `NodeView` through **28** (node-inventory), `ApprovalView`
through **20** (operation binding 15–20). Verify against the current file before claiming.

| Message · field range | Content | Owner | State | TASK |
|---|---|---|---|---|
| NodeView · …28 | inventory fields (pre-Olympus) | hephaestus | merged | — |
| ApprovalView · 15–20 | operation-binding columns (pre-Olympus) | hephaestus | merged | — |
| | | | | |

## Server image tag train (`alpha-X.Y.ZaN` — claiming aN reserves the CI build slot)

Tag **push** itself is a release op (zeus's hands, rules/03). Known at setup: train moved to
`alpha-0.2.2`; `a1` deployed 2026-07-15. Verify `git tag -l 'alpha-*'` before claiming.

| Tag | Content | Owner | State | TASK |
|---|---|---|---|---|
| alpha-0.2.2a1 | strict backing + secret storage + execute protocol (pre-Olympus, deployed) | zeus | merged | — |
| alpha-0.2.2a3 | lattice-server image tag (integration 755aaff: TASK-0008/0022/0023 + reconciliation) | zeus (operator-delegated 2026-07-27) | merged | TASK-0010 |
| alpha-0.2.2a4 | lattice-server image tag (integration c9c67107: dashboard.ref -> reconciled tip, closes pin-graph G2) | zeus (operator-delegated 2026-07-27) | merged (deployed 2026-07-27) | TASK-0010 |
| alpha-0.2.2a5 | lattice-server image tag (integration 1e61030 + dashboard.ref -> 04c4046: NetGuard reality chain, dev-plugin loop, plugin-trust surface, trust banner) | zeus (principal-delegated 2026-08-04) | merged (deployed 2026-08-04) | TASK-0010 |
| alpha-0.2.2a6 | lattice-server image tag (integration 4e41f14: subscription shares, public distribution, snapshot fallback, probe resistance, subscription:serve capability) | principal | merged (deployed 2026-08-05) | TASK-0023 |
| | | | | |

## RBAC scopes & host capabilities (lattice-server rbac + plugin manifests)

One name, one meaning, everywhere: scope strings (`netguard:admin`, `plugin:admin`,
`secret:read/write`, `task:run`, `substore:*`…) and capability names must not be minted twice
or reused across semantics (the wireguard scope-name confusion is the cautionary tale).

| Name | Meaning | Owner | State | TASK |
|---|---|---|---|---|
| v0.1.0-alpha.1 | lattice-plugin-bridge first publish tag | zeus (operator-delegated) | claimed | TASK-0004 |
| `subscription:serve` (capability) | A plugin may produce the BODY of a subscription the core serves on an unauthenticated public URL. Grants no route, no port, no listener, no response header and no access to the share token. Host-risk, system-only, NOT exempt for non-system plugins | principal | merged (shipped in alpha-0.2.2a6) | TASK-0023 |

## Plugin ids · service/method names · manifest versions

Plugin ids are global (`latticenet.<name>`); service+method tuples are wire contract; manifest
`version` bumps lock-step with artifact rebuilds (digest changes ⇒ zeus re-signs).

| Resource | Value | Owner | State | TASK |
|---|---|---|---|---|
| `latticenet.sub-store` manifest version | 0.5.0-alpha.1 (signed; bundle digest ca82b389) | principal | merged (deployed 2026-08-05) | TASK-0023 |
| `latticenet.sub-store/subscription` service | 11 methods: fetch, render, operators, preview, list, migrate, export, import, get_settings, save_settings, publish | principal | merged | TASK-0023 |
| | | | | |

## Ports (dev servers, plugin sidecars, node inbounds)

Known at setup: dashboard dev 5273 (Vite); fleet inbound port ranges are allocated in the
operator's **private** notes, never in this public ledger — claim a reference here, keep values
there; Sub-Store sidecar default 127.0.0.1:3000 (TASK-0002 claims the final value).

| Port / range | Purpose | Owner | State | TASK |
|---|---|---|---|---|
| | | | | |

## API route prefixes & dashboard routes / plugin view ids

Server `/api/<prefix>/**` namespaces and dashboard route paths (`/map`, `/plugins/<id>`…).

| Resource | Value | Owner | State | TASK |
|---|---|---|---|---|
| | | | | |

## Server state.json collections (encrypted-envelope wiring is mandatory)

New top-level State collections must wire `encryptedState`+`decryptState`+`stateHasEnvelope`
(or explicitly record why plaintext is safe) — the silent-plaintext failure mode is documented
in memory. Claim the collection name here first.

| Collection | Content | Owner | State | TASK |
|---|---|---|---|---|
| GuardRealitySnapshots | Latest normalized low-trust `GuardNodeReality` per node plus server `received_at`; plaintext by design because raw payloads, tokens, stderr, key material, and secrets are forbidden from this collection | hephaestus | in_progress | TASK-0017 |
| SubscriptionShares (merged 4e41f14) | One publicly reachable subscription URL: slug, token, source, format, lifecycle. `Token` IS wired through `encryptedState`/`decryptState` — it is a bearer credential for an unauthenticated URL, the same class as `ProxyUser.SubToken` beside it. `Slug` stays plaintext deliberately: it already appears in reverse-proxy access logs, so sealing it would imply a secrecy it does not have. Excluded from the JSON state when the bolt hot store is enabled | principal | merged | TASK-0023 |
| SubscriptionSnapshots (merged 4e41f14) | Last content a plugin successfully fetched for one subscription, keyed `(plugin_id, subscription_id)`. **Plaintext by design**: it is public subscription content the provider already served over the network to anyone holding the URL, so a cipher pass per refresh would buy nothing. The provider URL itself never enters this collection — only the response body and its traffic header. Excluded from the JSON state when the bolt hot store is enabled, because these are provider payloads rewritten on every refresh | principal | merged | TASK-0023 |
| | | | | |
