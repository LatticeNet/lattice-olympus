---
task: TASK-0018
title: Carry reviewed publisher-seed exclusions into plugin integration branches
owner: zeus
status: in_progress
plan_ref: TASK-0007 leftover discovered by 2026-08-03 live backlog audit
repos: [lattice-plugin-index, lattice-plugin-netguard, lattice-plugin-sub-store, lattice-plugin-template, lattice-plugin-vpn-core, lattice-plugin-wireguard]
branches: [feat/zeus-task0018-seed-guard-carry, feat/zeus-task0018-seed-guard-carry-r2]
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

- [x] six fresh Zeus worktrees/branches registered from exact current integration tips; shared
      clones and other-seat worktrees untouched
- [x] each delta is `.gitignore` only and preserves current entries plus all reviewed seed
      exclusions — proven by a named six-repo mechanical check with expected count 6
- [x] per-repo required test/lint/build gates pass on each exact carry head; failures are reported
      per repo, never hidden by an aggregate success
- [ ] affected plugin owners `[ack]` the exact carry heads
- [ ] six branches land independently on integration with post-merge quick regressions
- [ ] six stale Drafts receive the landing commit comment and close only after their repo lands
- [ ] all six Zeus worktrees removed after landing; no other worktree removed
- [ ] TASK-0007 memory/backlog map updated and finish letter sent

## Log (append-only, newest first)

- 2026-08-04T08:18Z: bounded r2 recovery is now externally visible and fully green. Five new
  commit objects preserve the respective r1 tree, ordered two-parent vector, author/committer
  identity, and timestamps byte-for-byte; their only message delta removes blank separators
  between Lore fields, changing native parsing from 1/8 to 8/8. Exact recovery heads and Drafts:
  plugin-index `e5be8f746a87eebc43e6a664960f8ff74131b44b`/#5, NetGuard
  `f1cfc7c315b79c9b7835322bc29087935dcda41d`/#6, Sub-Store
  `38d34d32436dcef3ceda8aaae12736825726a5f7`/#10, template
  `9c4f595655928a17ef1932944ce2ce0b5bd730c0`/#9, and WireGuard
  `867221c9dfc27169f49b650975e4c660ad6c9e78`/#6. Each branch was pushed by explicit object after
  rechecking its unchanged integration base. Every delta remains `.gitignore` only, 11 additions,
  with 8/8 fixed guard expectations and a clean worktree. Local exact-head gates pass: index
  validator 1 accepted/7 rejected; the four rebuilt plugins pass Go 1.26.4 race suites, UI
  test/typecheck/build/scan, released-server manifest validation, linux amd64/arm64 builds, and
  byte-identical deterministic packages at their existing manifest digests. Automatic GitHub CI
  is SUCCESS on all five (index 2/2; each plugin 1/1). The five malformed r1 Drafts were annotated
  with their replacements and closed only after the new Drafts existed; every old remote branch
  remains at its exact r1 head. vpn-core remains unchanged at OPEN Draft #7 / exact head
  `87af11796c5e4773ebbdaea6e9303cdfbf7e0cf1`, base `0d819917f406cd01f9dd416dd9844f7e99538022`,
  8/8 native trailers, automatic CI SUCCESS. Fresh batched r2 owner review is requested; no r1 ack
  carries over and no integration merge has occurred.

- 2026-08-04T07:36Z: the human principal confirmed the frozen exact range twice in-session:
  remote base `17b847b9619195ad0d3ac74b31012ef0cfb976b7`, local head
  `b89829748b0fd8fa996d411dbc56c57ad4d43721`, the recorded ordered nine-commit vector, and
  scanner result 9 commits / 1 violation / 61 physical / 8 escaped / 61 parsed / exit 1. Final
  fetch found the same base; all four values matched before rebase; the rebase was a no-op; all
  four matched afterward; ordinary explicit-object push advanced Olympus main to exact `b898297`.
  Post-push Touch is clean and the new outbound scan is 0 commits / 0 violations. Athena r2
  `adefd8a` and Hephaestus r2 `e6cbd81` are both native-clean; changelog row #10 is now co-signed
  and in force. The five same-base/same-tree/same-parent-vector `-r2` code recovery branches are
  now authorized; vpn-core remains unchanged.

- 2026-08-04T07:10Z: additive correction and row #10 r2 candidate committed locally as
  `16af3fa504842565166366699eacd5a07d00cbf9`; its 10/10 native trailers parse. Independent rule
  critique returned `[ack]` after helper failure became loud exit 2 and the exact-range ruling was
  bound before rebase. Fresh r2 co-sign requests are sent to Athena and Hephaestus. Olympus remains
  unpushed and the strict outbound scan remains red by design; no recovery branch exists.

- 2026-08-04T06:50Z: row #10 r1 is rejected and superseded by an unapproved r2 draft. Independent
  rule review proved §3.1 correctly models code task heads but cannot model Olympus's direct shared
  `main`. Native controls are exact: `4496c52` parses 9/9; already-pushed `17b847b` stores seven
  literal-escaped Lore keys and parses 0; shared-local `45eefd4` stores eight and parses 0. The
  latter is no longer the tip because Hephaestus's valid TASK-0019 request `7710d06` follows it, so
  neither rewriting nor a HEAD-only check is lawful. r2 separates same-tree/same-parent-vector code
  recovery from append-only Olympus correction and adds a strict full-outbound scanner with no SHA
  waiver. Its 10/10 harness covers valid, paragraph-separated, literal-escaped, non-tip,
  no-trailer, invalid-ref, helper failure, and all three real objects. The current two-commit
  outbound range predictably exits
  1: one violation, physical 7, escaped 8, parsed 7. No r2 branch, push, merge or co-sign exists.

- 2026-08-04T06:36Z: Hephaestus r1 returned `[request-changes]` on five commit objects, not on
  their content: index `f12ca14`, NetGuard `ca0f00d`, Sub-Store `a1e9115`, template `00b50c0`,
  and WireGuard `3130d94` separate every intended Lore field with blank paragraphs, so native
  `git interpret-trailers --parse` recognizes only `Not-tested:`. vpn-core `87af117` parses all
  eight and is individually clean. All six `.gitignore` trees, parents, PR bases, automatic CI,
  tracked-path scans, and build obligations otherwise passed independent review. A follow-up
  commit cannot repair immutable metadata; force-push is forbidden; and current rules also forbid
  a replacement task branch. Proposed rules/01 §3.1 + changelog row #10 resolves that conflict by
  preserving the failed branch/PR and allowing exactly one same-base, identical-tree numbered
  recovery branch with full gates and fresh review. The rule is not in force until Athena and
  Hephaestus co-sign; no r2 branch or merge exists. Athena's independent r1 remains in progress.

- 2026-08-04T05:38Z: all six exact carry heads now exist as unique OPEN Draft PRs against their
  unchanged integration bases: index `f12ca14`/#4, NetGuard `ca0f00d`/#5, Sub-Store
  `a1e9115`/#9, template `00b50c0`/#8, vpn-core `87af117`/#7, and WireGuard `3130d94`/#5.
  The predicted six-repo mechanical proof returned exactly 6/6: every worktree is registered and
  clean, every delta is only `.gitignore` with 11 additions/0 deletions, and every fixed guard is
  8/8. All required exact-head local suites pass: index validator 1 accepted/7 rejected; plugin
  Go 1.26.4 race suites; UI tests (NetGuard 3, Sub-Store 33, vpn-core 6, WireGuard 3),
  typechecks/builds/scans; released-server manifest validation; linux amd64/arm64 builds; and
  byte-identical deterministic packages matching existing manifest digests. Automatic CI is
  SUCCESS on all six exact heads, including Node 22 authority for Sub-Store after its optional
  local Node 22 wrapper download was stopped cleanly. Five UI installs report one existing
  moderate advisory; no dependency or lock change was allowed here. Batched r1 owner-review
  letters are sent to Hephaestus and Athena. No integration merge, signing/key/trust access,
  release, deploy, workflow dispatch, shared-clone write, other-seat worktree access, or worktree
  removal occurred.

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
