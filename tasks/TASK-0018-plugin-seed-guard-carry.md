---
task: TASK-0018
title: Carry reviewed publisher-seed exclusions into plugin integration branches
owner: zeus
status: in_progress
plan_ref: TASK-0007 leftover discovered by 2026-08-03 live backlog audit
repos: [lattice-plugin-index, lattice-plugin-netguard, lattice-plugin-sub-store, lattice-plugin-template, lattice-plugin-vpn-core, lattice-plugin-wireguard]
branches: [feat/zeus-task0018-seed-guard-carry]
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: yes
created: 2026-08-03
---

## Goal

Make every plugin integration branch actually exclude local publisher signing seeds. The seven
original PRs were batch-reviewed in TASK-0007, but only server's equivalent change landed; the six
plugin integrations still omit the reviewed block. Observable result: the six integration
`.gitignore` files contain the seed exclusions, their repo gates pass, and the stale main-based
Drafts are closed with the integration landing commits recorded.

## Scope & boundaries

- In: fresh Zeus-owned worktree per repo from current `origin/integration`; merge the existing
  `chore/gitignore-signing-seeds` branch as history; resolve only `.gitignore` by preserving all
  current integration entries plus the reviewed seed exclusions; exact-head owner review; ordinary
  no-ff integration landing; annotated closure of the superseded Draft.
- Out: server#9 (already landed/closed); template#3 execute-reference; sub-store#5 spike; signing,
  manifests, artifacts, tags, releases, deployment, or any plugin runtime/UI behavior.
- **Allowed paths**:
  - `lattice-plugin-index/.gitignore`
  - `lattice-plugin-netguard/.gitignore`
  - `lattice-plugin-sub-store/.gitignore`
  - `lattice-plugin-template/.gitignore`
  - `lattice-plugin-vpn-core/.gitignore`
  - `lattice-plugin-wireguard/.gitignore`
- **Forbidden**:
  - never edit or switch a shared sibling clone;
  - never enter, change, or remove another seat's `.wt/` path;
  - no seed/key/trust material may be generated, read, copied, or named by path;
  - no version, digest, signature, manifest, workflow, release, or production change.

## Notes

- Source PRs: plugin-index#1, netguard#1, sub-store#1, template#1, vpn-core#1, wireguard#1.
- Existing TASK-0007 review is semantic evidence, not a substitute for fresh exact-head owner
  review after merging current integration into each carry branch.
- Shared `lattice-plugin-index/` is currently clean but historically checked out on
  `feat/design-15-alpha-index`; it is quarantined read-only. TASK-0018 must create a fresh Zeus
  worktree from the reviewed integration tip.
- Batch the owner review requests, but merge and verify repos independently so one failure cannot
  silently create a partial-success report.

## DoD

- [ ] six fresh Zeus worktrees/branches registered from exact current integration tips; shared
      clones and other-seat worktrees untouched
- [ ] each delta is `.gitignore` only and preserves current entries plus all reviewed seed
      exclusions — proven by a named six-repo mechanical check with expected count 6
- [ ] per-repo required test/lint/build gates pass on each exact carry head; failures are reported
      per repo, never hidden by an aggregate success
- [ ] affected plugin owners `[ack]` the exact carry heads
- [ ] six branches land independently on integration with post-merge quick regressions
- [ ] six stale Drafts receive the landing commit comment and close only after their repo lands
- [ ] all six Zeus worktrees removed after landing; no other worktree removed
- [ ] TASK-0007 memory/backlog map updated and finish letter sent

## Log (append-only, newest first)

- 2026-08-04T03:35Z: NetGuard carry is pushed as Draft PR #5 at exact head
  `ca0f00d365802043ffdd5938aae20a83f3ced862`, based on unchanged
  `origin/integration@9822d816`. The explicit two-parent Lore merge preserves reviewed source
  `dec87a7`; its delta from integration is exactly `.gitignore`, 11 additions. Fixed seed-guard
  expectations are 8/8. On the exact head, Go 1.26.4 race tests passed for `system-go` and
  `tools/pluginpack`; UI tests passed 3/3 with typecheck, build, and build scan; the released-server
  manifest validator accepted id/version/schema; linux amd64/arm64 builds passed; and two
  deterministic packages were byte-identical at the signed manifest digest
  `ac7e1d66b75a911b82f378999c0323c08917fa9d8030046bf790c64eb147b81c`. PR #5 is OPEN,
  Draft, MERGEABLE, and exact at `ca0f00d`; automatic CI is running. No workflow dispatch,
  signing, key/trust access, release, deployment, shared-clone write, or other-seat worktree access
  occurred. Owner review remains intentionally batched until all six heads exist.

- 2026-08-03T12:55Z: plugin-index carry is pushed as Draft PR #4 at exact head
  `f12ca14373fb0c3477b722e0a56f57394a2bc0f2`, based on unchanged
  `origin/integration@a54bb9e`. The commit is an explicit two-parent merge of integration plus
  reviewed source `ec155ce`; its delta from integration is exactly `.gitignore`, 11 additions,
  preserving the newer `.omc/` entry. Fixed guard expectations are 8/8. `npm test` passes with
  one accepted and seven rejected train fixtures before and after commit; diff-check is clean.
  The push/PR-create processes were checked for ambiguous completion: the branch and Draft #4
  both exist exactly once at the expected head. No shared clone, index data, version, artifact,
  signing, release, or another worktree changed. Owner review will be batched after the remaining
  plugin carry heads are prepared.

- 2026-08-03T12:50Z: started the plugin-index slice first because it is also the TASK-0010 train
  manifest home. Fetched current integration and the reviewed source branch, then created the
  registered Zeus-only worktree `.wt/zeus-task0018-plugin-index` on
  `feat/zeus-task0018-seed-guard-carry` from exact `origin/integration@a54bb9e`. The shared
  `lattice-plugin-index/` checkout remained untouched on its historical feature branch; no other
  worktree was entered or changed. Next: merge the source history, resolve `.gitignore` only,
  prove the expected exclusions and run the index gates before owner review.

- 2026-08-03T12:36Z: created as a truthful carry task after exact GitHub comparison showed all six
  reviewed plugin seed PRs diverged from integration and each current integration `.gitignore`
  lacks the eleven-line exclusion block. Server's seventh PR is excluded because its exact blob
  already landed as `748bb05` and stale PR #9 was annotated and closed. No code repo changed.
