---
slug: map-draft-pr-backlog
kind: map
keywords: draft PR backlog, critical path, verdicts, landed-in-integration, close-with-landing-commit, integration behind main
added: 2026-07-26
verified: 2026-07-26
by: zeus
---

**The load-bearing fact (TASK-0001, 2026-07-26)**: the eight "critical-path" PRs were already
CONTAINED in their repos' `integration` branches at Olympus setup — integration was cut from
alpha tips that had absorbed them unreviewed. Review was retroactive scrutiny; the PRs end as
close-with-landing-commit (rules/01 §8.5), never merged. Exception: dashboard
`feat/bridge-host-origin` (no PR; tree identical to dashboard main tip a927c6c).

**Verdicts on record (letter 20260726-0746Z, evidence therein)**:
- server#7 gateway-hardening [ack] · #8 backing [ack, Low: RPC Call checks lifecycle before
  grants → probe leak + wrong comment] · #10 require-backing [ack] · #11 secret-storage
  [ack, caveat: envelopes have no AAD — relocation attack, pre-existing, needs envelope-v2
  decision] · #12 operation-execute [ack] · sdk#6 typed-approval-columns [ack] ·
  dashboard#9 frame-reload-boundary [pending dashboard suite at verdict time].
- Suite evidence: server integration tip 86422a1 full `-race -cover` green (internal/server
  397.6s @ 69.8%); sdk tip e510bd7 green.

**Integration-behind-main divergences found (integrator ruling pending)**:
- sdk: integration e510bd7 vs main 4a318f2 — SIBLINGS of 4623d3b; both carry the Approval
  columns (identically); main additionally has design-15 LineUUID/DownstreamLineUUID +
  ADR-004 SingBoxStatsAPI. Server integration pins sdk@MAIN-tip, not sdk@integration.
- dashboard: integration a40af9a missing main tip a927c6c = squash of feat/bridge-host-origin
  (host_origin in frame fragment + scope-migration fail-closed; SECURITY fix).
- sub-store: integration 3c3571f missing main tip 1d18c3b (design-15 vault) — athena's find.
- server: healthy (main ⊆ integration).

**Two-sided deploy law (server#8/#10 × plugin re-signs)**: staged order executed in production
2026-07-15, but binds again for fresh nodes from pre-backing bundles and for any server
rollback past #8 (strands re-signed plugins). #7 adds: no LATTICE_PUBLIC_URL → plugin assets
503 (same family as [[decision-webauthn-rpid]]).

**Remaining open drafts (TASK-0007 scope)**: dashboard #3 lines / #4 sidebar / #5 passkeys
(#6 inventory no longer open — verify how it landed); plugin re-sign PRs (vpn-core/netguard/
wireguard/sub-store/template #2, template#3); plugin-index#1; gitignore-signing-seeds family.
[[gotcha-published-vs-acceptable-manifest]] [[decision-plugin-backing]]
