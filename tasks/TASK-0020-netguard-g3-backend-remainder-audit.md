---
task: TASK-0020
title: NetGuard G3 backend remainder audit
owner: hephaestus
status: in_progress
plan_ref: lattice/docs/designs/design-13-wireguard-and-netguard-plugins.md §9 G3
repos: [lattice-server, lattice-sdk, lattice-node-agent, lattice-plugin-netguard]
branches: []
last_touched_by: hephaestus
depends_on: [TASK-0015, TASK-0016, TASK-0017, TASK-0019]
blocked_by_ruling: Zeus G3 read-surface and apply-state semantic gate requested 2026-08-04T11:48Z
needs_ack: yes
created: 2026-08-04
---

## Goal

Map every remaining design-13 §9 G3 exit criterion against exact current integration after
TASK-0015/0016/0017/0019. The observable Phase 0 result is an evidence-backed matrix showing
whether suggestion exposure, reality freshness/drift, Review & Re-apply inputs, and binding
apply-state persistence are complete in Hephaestus-owned backend code, with exact paths and named
tests. Implement nothing unless that audit proves a smallest missing backend slice exists.

## Scope & boundaries

- In:
  - Read-only comparison of design-13 §9 G3 and contract/api-contract.md §2 against current
    integration objects in server, SDK, node-agent, and NetGuard plugin backend.
  - Exact path, symbol, route, persistence, and named-test evidence for each G3 criterion.
  - A binary conclusion: amend this task for the smallest Hephaestus-owned backend delta, or finish
    as already complete and hand the UI remainder to Athena.
- Out:
  - Dashboard or plugin `ui/**`, manifests/signatures, workflows, release files, live discovery,
    release, deployment, CI dispatch, and every ops surface.
  - Auth, approval, plan/apply, or apply-state semantic changes during Phase 0.
- **Allowed paths for Phase 0**:
  - `lattice-olympus/tasks/TASK-0020-netguard-g3-backend-remainder-audit.md`
  - `lattice-olympus/status/hephaestus.md`
  - `lattice-olympus/messages/inbox/{zeus,athena}/20260804-*-hephaestus-*.md`
  - the two exact consumed letters in `lattice-olympus/messages/inbox/hephaestus/`
- **Forbidden**:
  - No code-repository edits, branches, worktrees, commits, tests that invoke live discovery, or
    another seat's worktree access during Phase 0.
  - If a backend gap is found, amend this task with exact owned paths and tests before taking a
    fresh worktree. Any auth/approval/apply semantic delta also requires a fresh Zeus review gate.

## Notes

- Zeus-provided current integration anchors: server `1e6103001f16d48110bce471d68e6e638e805ada`,
  SDK `00943f6ec9e78f27f0dc18f1bc43c11decba4f8f`, node-agent
  `bbcc26c8fa271f3ae2f068ca10f2ed7b6d55372f`, NetGuard plugin
  `22ea8e5a819df14cfe789e608a20041e8f2fcef4`.
- TASK-0015 supplies the fail-whole collector, TASK-0016 the deterministic suggestion core,
  TASK-0017 latest-snapshot persistence/read API, and TASK-0019 opt-in poll transport.
- Reality is low-trust display/diff input only. It must not silently author policy or mutate apply
  state.

## Phase 0 exact-integration audit

All four remote `integration` refs were re-read from origin on 2026-08-04T11:47Z and equal the
recorded anchors exactly: server `1e6103001f16d48110bce471d68e6e638e805ada`, SDK
`00943f6ec9e78f27f0dc18f1bc43c11decba4f8f`, node-agent
`bbcc26c8fa271f3ae2f068ca10f2ed7b6d55372f`, and NetGuard plugin
`22ea8e5a819df14cfe789e608a20041e8f2fcef4`.

| G3 criterion | Classification | Exact evidence | Proof / missing proof |
|---|---|---|---|
| Suggestion exposure | **backend gap** | The deterministic engine is `lattice-server/internal/netguard/suggest.go:52` (`Suggest`). No server route calls it: `internal/server/server.go:920-928` registers groups/zones/nodes/reality/bindings/adopt/plan only. Core plugin RPC `internal/server/server_network_plugins.go:101-104,114-158` registers overview and G2 writes/plan only. Plugin `system-go/main.go:51-84` implements describe/health/plan and only describes suggestions at line 63. | `TestSuggestMissingAllowAndStaleAllow`, `TestSuggestOverlayOnlyListenerAndUntrustedZone`, `TestSuggestManagedTableDrift`, `TestSuggestBindingOverridesAreIntent`, `TestSuggestCIDROverlayZone`, and `TestSuggestCleanIntentNoSuggestions` prove the pure engine. No REST/RPC exposure test exists. |
| Drift computation and poll freshness | **partial; backend gap prevents exit** | Agent `internal/guardreality/collect.go:273-321` canonicalizes the live `inet lattice_guard` JSON, strips volatile handles, and hashes it. `cmd/lattice-agent/main.go:387,659-668` reports once per enabled poll. Server `server_netguard_reality.go:147-232` serves latest snapshot plus server-authoritative `unknown|fresh|stale`. `internal/netguard/suggest.go:67,468` compares non-empty `Binding.AppliedTableSHA` and `Reality.ManagedSHA`. However no production path ever sets `AppliedTableSHA`, so drift cannot flip within a poll interval. | `TestCollectBuildsRealityFromInjectedCommands`, `TestParseNFTRulesetIgnoresHandlesWhenHashingManagedTable`, `TestReportGuardReality` (disabled/success/collection failure/server failure/next-cycle recovery), `TestNetGuardRealityAgentWriteAndReadContract`, `TestNetGuardRealityValidationAndStaleConflicts`, `TestNetGuardRealityReadVisibilityAndPagination`, and `TestSuggestManagedTableDrift` prove the isolated pieces. No end-to-end drift transition test exists. |
| Review & Re-apply inputs | **partial; backend gap** | G2 intent and plan inputs exist in `internal/server/server_netguard.go`: `nodeGuardView` (lines 35-42), stored/legacy node views (115-174), and plan (551-627). Reality detail exists separately in `server_netguard_reality.go`. Core plugin `overview` returns only groups/zones/nodes (`server_network_plugins.go:114-143`), not reality, suggestions, drift, or a server-authoritative re-apply state. | `TestNetGuardAdoptThenPlan`, `TestNetGuardTrustedZoneClearsLockoutAndRendersIifname`, `TestNetGuardRealityAgentWriteAndReadContract`, and `TestNetGuardRPCReusesValidationAndReturnsOverview` prove the separate inputs. No test proves a consumer can obtain suggestions + drift + current binding/apply state for review and re-plan. |
| Binding apply-state persistence | **backend gap** | SDK fields exist at `lattice-sdk/model/model.go:668-686`. Store serializes the entire binding at `lattice-server/internal/store/store.go:2498-2521`, but the operator upsert accepts those fields from the request and overwrites them. `handleNetGuardPlan` creates a plain `Plugin:"nft", Action:"apply-ruleset"` approval without setting `LastPlanSHA` (`server_netguard.go:601-626`). `handleApprovalTaskResult` handles `nftpolicy` but returns for plain `nft` (`server.go:5973-6001`). Exact-tree grep finds no production use of `AppliedTableSHA` and no binding write of `LastPlanSHA`, `LastAppliedAt`, or `LastError`. | No named test proves server-authoritative binding plan/apply state, stale-plan rejection, task success/failure writeback, or canonical applied-table SHA capture. Existing `TestNetGuardStoreVersionConflicts` proves authoring concurrency only. |

### Binary conclusion and bounded next slice

The G3 backend is **not complete**; an Athena-only UI handoff would invent state the backend does
not provide. The smallest complete backend remainder is one gated protocol with two bounded parts:

1. A read-only server projection for per-node suggestions, drift, freshness, current binding, and
   re-plan inputs, reusing `netguard:read` and the in-force reality visibility rules. Prefer a new
   route or a separately ruled core RPC shape rather than silently changing API-contract §2's fixed
   reality response. The current signed plugin manifest exposes no reality/suggestion method;
   manifest/signature/UI changes remain out of this task.
2. Server-authoritative binding operational state: clients cannot author Last*/AppliedTableSHA;
   NetGuard plans record and approval-check the exact plan hash; a successful apply records
   `LastAppliedAt` plus the same canonical managed-table SHA the collector computes; failure/stale
   results record `LastError`. Reality ingestion remains low-trust and never writes apply state.

Proposed owned code paths after Zeus rules the contract are limited to:

- `lattice-server/internal/server/server_netguard.go` and tests;
- `lattice-server/internal/server/server_netguard_reality.go` and tests;
- `lattice-server/internal/server/server_network_plugins.go` and tests only if the ruled read shape
  is core-RPC-backed without manifest changes;
- `lattice-server/internal/server/server.go` plus focused approval/task-result and nft-script tests;
- `lattice-server/internal/store/store.go` plus focused binding-state persistence tests;
- `lattice-node-agent/cmd/lattice-agent/main.go` and focused injected-runner tests only if Zeus
  accepts an agent helper that emits the collector's canonical managed-table SHA to the trusted
  apply task result.

No SDK model change is presently required; no NetGuard plugin `system-go/**` change can expose a
core-backed interface, and manifest/signature/UI work remains expressly excluded. No code branch
or worktree may be created until the fresh Zeus contract/apply gate is persisted.

## DoD

- [x] all four remote integration refs equal the recorded anchors
- [x] each G3 criterion is classified implemented/backend-gap/UI-remainder with exact paths
- [x] named tests prove implemented collector, suggestion, persistence/API, freshness/drift, and
      apply-state behavior; unproved claims are recorded as gaps
- [x] Review & Re-apply inputs and binding apply-state persistence are traced end to end without
      changing auth/approval/apply semantics
- [x] conclusion is persisted: smallest owned backend slice with amended scope, or backend-complete
      proof plus Athena UI handoff
- [x] Phase 0 changes remain only in the allowed Olympus-owned paths above
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-08-04T11:48Z: Phase 0 proved a backend gap. The collector/poll, normalized latest snapshot,
  server freshness, SDK fields, and deterministic suggestion/drift core exist, but no route or core
  RPC exposes suggestions; the plugin overview omits reality/drift; no production path writes any
  binding apply-state field; and no test proves a poll-driven drift transition or Review & Re-apply
  input surface. Persisted exact path/test matrix and sent Zeus a fresh read-contract/apply-state
  gate request. No code branch, worktree, test, auth/apply change, UI/manifest/signature/workflow,
  live discovery, release, deployment, CI dispatch, ops action, or other-seat worktree access.
- 2026-08-04T11:40Z: claimed Phase 0 after TASK-0018 finish and Zeus remainder handoff. The audit
  starts branchless and read-only from the four recorded integration anchors. No code repo,
  worktree, UI, manifest, workflow, signing, release, deployment, CI dispatch, live discovery, or
  auth/approval/apply behavior is touched.
