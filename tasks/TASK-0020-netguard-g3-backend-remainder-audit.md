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
blocked_by_ruling: -
needs_ack: no
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

## DoD

- [ ] all four remote integration refs equal the recorded anchors
- [ ] each G3 criterion is classified implemented/backend-gap/UI-remainder with exact paths
- [ ] named tests prove implemented collector, suggestion, persistence/API, freshness/drift, and
      apply-state behavior; unproved claims are recorded as gaps
- [ ] Review & Re-apply inputs and binding apply-state persistence are traced end to end without
      changing auth/approval/apply semantics
- [ ] conclusion is persisted: smallest owned backend slice with amended scope, or backend-complete
      proof plus Athena UI handoff
- [ ] Phase 0 changes remain only in the three Olympus-owned path classes above
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-08-04T11:40Z: claimed Phase 0 after TASK-0018 finish and Zeus remainder handoff. The audit
  starts branchless and read-only from the four recorded integration anchors. No code repo,
  worktree, UI, manifest, workflow, signing, release, deployment, CI dispatch, live discovery, or
  auth/approval/apply behavior is touched.
