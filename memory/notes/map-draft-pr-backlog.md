---
slug: map-draft-pr-backlog
kind: map
keywords: draft PR backlog, critical path, verdicts, landed-in-integration, close-with-landing-commit, integration behind main
added: 2026-07-26
verified: 2026-08-04
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
  dashboard#9 frame-reload-boundary [ack — 38/38 + type-check + build green at tip a40af9a] ·
  bridge-host-origin [ack as content — no PR; tree == main tip a927c6c, green 36/36].
- Suite evidence: server integration tip 86422a1 full `-race -cover` green (internal/server
  397.6s @ 69.8%); sdk tip e510bd7 green.

**Integration-behind-main divergences found (integrator ruling pending)**:
- sdk: integration e510bd7 vs main 4a318f2 — SIBLINGS of 4623d3b; both carry the Approval
  columns (identically); main additionally has design-15 LineUUID/DownstreamLineUUID +
  ADR-004 SingBoxStatsAPI. Server integration pins sdk@MAIN-tip, not sdk@integration.
- dashboard: TWO-WAY divergence — main lacks #9 (frame-reload security fix, 38-test suite);
  integration lacks a927c6c = squash of feat/bridge-host-origin (host_origin declaration +
  scope-migration fail-closed, 36-test suite). Each line is missing a security fix the other
  has; reconciliation is a true merge (expect 43 tests combined). Both tips verified green
  independently (2026-07-26).
- sub-store: integration 3c3571f missing main tip 1d18c3b (design-15 vault) — athena's find.
- server: healthy (main ⊆ integration).

**Two-sided deploy law (server#8/#10 × plugin re-signs)**: staged order executed in production
2026-07-15, but binds again for fresh nodes from pre-backing bundles and for any server
rollback past #8 (strands re-signed plugins). #7 adds: no LATTICE_PUBLIC_URL → plugin assets
503 (same family as [[decision-webauthn-rpid]]).

**TASK-0007 state (2026-07-26)**: closed-as-landed with landing commits — server#3/#4
(a0308cb), dashboard#5/#4 (0115575), dashboard#3 (5c3d82f), sub-store#2 (int tip 3c3571f);
dashboard#6 was properly MERGED. [ack] merge-ready, awaiting integrator pass — seeds ×7
(history re-scanned clean in all 7 repos), backing ×4 (conformance -race green per head;
signatures rest on 2026-07-15 field load "4/0"), template#3 execute-reference (-race green;
injection test real; manual e2e owed).

**Signing-seed carry reconciled (TASK-0018, 2026-08-04)**: server#9 had already landed as
`748bb05`; the remaining plugin-index, NetGuard, Sub-Store, template, vpn-core and WireGuard
changes now land on their `integration` branches as independently reviewed no-ff merges. Their
current integration PRs are MERGED; stale main-targeting source Drafts #1 are linked to the exact
landing commits and CLOSED. Source and recovery branches remain preserved for audit. Template#3
execute-reference and Sub-Store#5 engine spike remain separate semantic work, not seed-guard
leftovers. Still open beyond this queue: server#7/#8/#10/#11/#12, sdk#6, dashboard#9
(TASK-0001 closure sweep, operator-gated) + athena's sub-store#4 (her round protocol).
[[gotcha-published-vs-acceptable-manifest]] [[decision-plugin-backing]]
