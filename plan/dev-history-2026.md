# Lattice development history digest (through 2026-07-25)

> Snapshot at Olympus instantiation. Working sessions read `memory/notes/decision-plan-digest`
> instead of this file; this is the long-form record. Sources: Claude Code persistent memory,
> Codex CLI session archives, git history across the LatticeNet org.

## What Lattice is

Self-hosted multi-node VPN/proxy control plane: Go server (`lattice-server`, single binary +
JSON state, Docker-deployed), Vue 3 dashboard (`lattice-dashboard`), Go SDK (`lattice-sdk`,
models + proto), node agent (`lattice-node-agent`, sandboxed task executor polling over HTTP),
a signed-plugin system (template + vpn-core, netguard, wireguard, sub-store + index), a
sing-box fork (`lr00rl/sing-box`) carrying `_lattice` metadata, and the docs site
(`latticenet.github.io`). The deployed fleet's topology, node inventory, and security posture
live in the operator's **private** notes — never in this public repo.

## Timeline of major deliveries

### 2026-06-17/28 · Astra is born
A SwiftUI app converted into a phone-first Lattice client (`Astra` repo): live node telemetry,
server diagnostics, reviewed network operations. Built entirely direct-to-main (pre-protocol).

### 2026-06-27→30 · Plugin extraction era
Live-dashboard UX critique established "enroll is the authoritative node creation path".
Proxy/Inbounds/Users/Subscriptions/Usage moved out of core into `vpn-core` + `sub-store`
plugins; the Tier-2 SystemRunner wired into the live RuntimeManager (plugins actually exec).
Followed by the big security sweep: enforced TOTP, node-token source allowlists, audit-WAL
anchors with off-box head custody, task cgroups / no-new-privileges / non-root agent, HTTPS-only
installer downloads, Lines secrets behind step-up 2FA.

### 2026-07-04 · Lines redesign (4 draft PRs)
Per-node row layout + true topology SVG + Map VPN-lines layer (dashboard#3); `NodeInventory`
model, proto NodeView field 28 (sdk#2); enroll/update/nodeView chain (server#3); sing-box#1
fixed the fatal `_lattice`-in-`inbounds[0]` crash loop by moving metadata to a sidecar file.
**Still missing: server-side `jump_edges` producer** (declared, never assigned).

### 2026-07-05 · Sidebar redesign + native passkeys (3 draft PRs) + stable 0.2.0
Kumo-style sidebar with pinned/recents/collapsible groups (dashboard#4). WebAuthn passkeys
(server#4, dashboard#5): go-webauthn, UV-required resident keys count as 2FA; RP identity
derived **only** from `LATTICE_PUBLIC_URL` (no new config fields); unset → 503 fail-closed.
Same day, the **coordinated stable 0.2.0 release**: server v0.2.0 · dashboard v0.2.0 ·
node-agent v0.3.0 · sdk v0.2.15 · docs — the release-order discipline dates from here.

### 2026-07-07 · Inventory redesign + fleet security audit
View-first Inventory with billing taxonomy and per-currency spend (dashboard#6). A read-only
fleet security audit recorded material gaps in SSH auth policy and host firewalls (findings and
per-node detail in the operator's **private** report; nothing pushed to prod — hardening rollout
gated on NetGuard maturity). sing-box config-dir model documented (`_lattice.line_id` join key,
chained lines via named outbounds). Server image tag scheme confirmed: `alpha-X.Y.ZaN` rapid
train, no base-version bumps.

### 2026-07-08/09 · design-13: WireGuard + NetGuard as signed plugins
Design doc + draft PR lattice#1. Implemented G1+G2+W1+W2 (sdk#5, server#6): netguard domain
model + compiler sunk into the single `GenerateNFTPlan` renderer (byte-parity structural
guarantee, mutation-tested); `lockout_risk_ssh` plan-time lint; WireGuard topology builder
(mesh byte-equal to legacy, hub-spoke, custom fail-closed); **WireGuard apply finally got the
watchdog/rollback** it lacked. Two new public plugin repos created (netguard, wireguard),
initially unsigned. Security finding: `rbac.Allows` with empty nodeID returns true for
allowlisted principals → node-scoped plugin interfaces withheld; recorded design-13 §10.8.

### 2026-07-09→14 · Bundle v2 + stable 0.2.1 train
Plugin-owned UI in an opaque-origin `allow-scripts` iframe with a nonce-bound postMessage
bridge, method-scoped RBAC, "no native plugin residue" in the console. Stable 0.2.1 line:
sdk v0.2.17 · dashboard v0.2.1 · server v0.2.1 · agent v0.2.9 · docs v0.2.1. Reviews ran as
parallel read-only lanes (code-reviewer / security-reviewer / architect / verifier on one diff).

### 2026-07-14/15 · Plugin boundary review → hardening wave (17+ draft PRs) → alpha deploy
Three-agent read-only architecture review, findings re-verified in source (full audit report in
the operator's private planning archive). Host trust boundary solid
(signatures, digest gates, bounded unzip, sandboxed iframe bridge, capability broker). Core
contradiction: only sub-store was truly self-contained; vpn-core/netguard/wireguard were
**signed façades** answered by in-core handlers via a silent publisher-based fallback, and
disable didn't stop backends. Ruling (user-approved option C): manifest-signed
`backing: runtime|core` per service, fail-closed on mismatch, conformance tests probing every
declared method. Delivered: reload-boundary fix (dashboard#9), gateway hardening (server#7),
backing field (server#8) + strict rejection (server#10), §9.4 encrypted secret storage
(server#11), §9.3 plan→approve→execute with typed Approval binding columns (server#12, sdk#6),
template execute reference (template#3), re-signed manifests ×5, gitignore seed guards ×7.
Alpha integration branches (`alpha/v*`) unified across repos; image `alpha-0.2.2a1` built via
tag-driven CI and deployed to the hub node with dry-run + full backup + verified
`4 loaded, 0 rejected`.

### 2026-07-22/23 · design-15 deep integration (in flight)
Resumed from a Kimi CLI handoff. Canonical vpncore/substore scope migration, sing-box sidecar
stats/accounting via a vendored gRPC client (ADR-004), durable line identity (`line_uuid` +
chain recognition), Sub-Store integration scope defined. Stacked draft PRs across
server/sdk/dashboard/plugin-index/sing-box; several server slices landed via `alpha/v0.2.2`
(their PRs #15–#19 closed as drafts). `lattice-plugin-sub-store` clarified as an **adapter**
to external Sub-Store endpoints — with import preview, an encrypted endpoint vault, cleartext
secret-URL refusal, and drift detection on feature branches.

## Codex CLI session history (inventory)

82 session files under the Codex archive, 2026-06-17 → 2026-07-23: 14 user-rooted threads +
68 spawned subagent lanes (code-reviewer ×19, executor ×13, explore ×10, architect ×9,
verifier ×6, security-reviewer ×5, debugger ×2, others ×3). Two threads dominate: the design-13
→ Bundle-v2 run (07-09→07-14, 43 files) and the design-15 run (07-22, 16 files). Recurring
shapes: parallel read-only review lanes ending "do not edit / do not merge / do not deploy";
hard convergence orders to over-exploring subagents; cross-tool handoffs (Claude Code → Codex
for check-and-deploy; Kimi → Codex session resume). Standing operator law observed in-session:
**UI changes are verified in a real browser, never by code inspection alone.**

## Open threads at instantiation

1. **The draft-PR backlog**: ~20 draft PRs across 9 repos, none reviewed/merged → TASK-0001.
2. `jump_edges` producer (server) — topology rendering path is waiting for it.
3. WireGuard Phase 4 real migration; NetGuard G3–G7 (reality/drift, dashboard, bootstrap…).
4. WebAuthn / Lines / Sidebar / Inventory features not yet in the alpha train.
5. Sub-Store plugin: today an **adapter** to external Sub-Store endpoints (endpoint vault,
   import preview, drift detection on feature branches; design-15 defines its integration
   scope) — the actual Sub-Store engine (Node.js) is **not** embedded yet
   → TASK-0002/0003 + `plan/design-substore-embed.md`.
6. Fleet hardening rollout (SSH password-auth nodes, firewall-less nodes) — gated, needs
   NetGuard maturity.
7. Secret envelope lacks AAD → ciphertext relocatable between records (known, recorded).
