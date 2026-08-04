---
task: TASK-0010
title: Coordinated public release train — one verified standard version across the fleet of repos
owner: zeus
status: in_progress
plan_ref: olympus-launch/operator-ruling-2026-07-26.md §1b (operator requirement)
repos: [lattice-olympus, lattice-sdk, lattice-server, lattice-dashboard, lattice-node-agent, lattice-plugin-template, lattice-plugin-vpn-core, lattice-plugin-netguard, lattice-plugin-wireguard, lattice-plugin-sub-store, lattice-plugin-index, latticenet.github.io]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # amends rules/01 §8.5 → co-sign per rules/02 §7; release mechanics stay operator-only
created: 2026-07-26
---

## Goal

LatticeNet publicly presents ONE verified standard version a user deploys or upgrades to —
server · dashboard · node-agent · sdk · every plugin — with mutual dependency pins explicit
and legible **from the release itself**, not from tribal knowledge.

Operator's stated model (ruling §1b):
- dev/test builds carry `vX.Y.Z-alpha.N` / `-beta.N` while the released line is `vX.Y.(Z-1)`;
- a train that passes verification is promoted to plain `vX.Y.Z` across the whole fleet as
  ONE coordinated act;
- cross-repo pins (server↔sdk↔dashboard refs, plugin↔server minimum version, plugin-index
  channel entries) resolve from the release artifacts themselves.

## Scope & boundaries (sliced — slice 1 depends on nothing)

- **Slice 1 — document the CURRENT pin graph (standalone, first deliverable)**: one document
  (home: `lattice` design-docs repo or latticenet.github.io — record the choice) mapping every
  cross-repo pin as it exists today: server's `sdk.ref` + `dashboard.ref` SHAs, each plugin's
  minimum-server expectation, plugin-index channel entries, node-agent↔server compatibility,
  Astra's pin if any. Every claim carries its source path (repo + file). No process change.
- **Slice 2 — the release-manifest format**: a machine-checkable release matrix (versions +
  pins + digests) that a train produces and a user can read; where it lives (likely
  plugin-index or a release asset per repo) and what CI validates.
- **Slice 3 — amend `rules/01 §8.5`**: add the promotion protocol (alpha/beta train →
  verification → coordinated `vX.Y.Z` cut) to the three-lane law. Rules change ⇒ co-sign per
  rules/02 §7; zeus holds the pen.
- Out: executing any release (operator-only, rules/03); changing the three tag lanes
  themselves; retroactive re-tagging.
- **Allowed paths**: docs + `rules/01` (slice 3, co-signed) + CI validation additions under
  the normal review flow. Tag pushes NEVER (operator hands).

## Notes

- The written release manifest/matrix must exist BEFORE the next stable cut (operator: hard
  requirement).
- Public-surface conditions apply (ruling §7): no internal hosts/IPs/fleet posture in any of
  it; latticenet.github.io updates ride the same work.

## DoD

- [x] slice 1: pin-graph document merged, every pin sourced (repo + file path), gaps named
- [x] slice 2: release-manifest format agreed (letter round) and validated by CI on at least
      one repo
- [x] slice 3: rules/01 §8.5 amendment co-signed and merged
- [x] operator sign-off that the next cut can run from this — **given 2026-08-04T13:50Z for the
      alpha lane only** (`alpha-0.2.2a5`). The stable `v0.3.0` promotion stays open: §8.5 forbids a
      plain train containing any prerelease component, and every plugin in the fleet is still a
      prerelease.
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-08-04T12:58Z: the operator started the first frozen Linux package and authenticated the
  browser through the loopback tunnel, but the live Plugins page authoritatively showed zero
  registered plugins. Read-only source inspection then proved the package launcher omitted four
  load-bearing server inputs: `LATTICE_PLUGIN_DIR`, private runtime/cache directories, and
  `LATTICE_PUBLIC_URL`. The dashboard's Verify dialog cannot repair that omission: its API is a
  preflight only and intentionally never installs or registers a bundle. One Sub-Store preflight
  form load was attempted; no install, lifecycle transition, plugin call, or browser PASS was
  claimed. The private package launcher and README are corrected locally: all five official
  bundles are now supplied to the startup loader, runtime/cache stay under the disposable state
  directory, and the plugin asset origin is the tunneled loopback URL. The checksum ledger now
  covers all 94 non-ledger files (94/94 pass); rebuilt 34 MiB archive SHA-256 is
  `424bdf65478ec6dda04522b762b2cd2ccc8c1404a888586c32d62f9ae8ee6b5f`. The running remote
  process is still the old zero-plugin launch and must be stopped/restarted by the human. After
  boot, the human must complete exact `verified -> installed -> active` environment setup for
  each loaded bundle before returning the session; Athena's matrix remains NOT VERIFIED. No
  production path, tag, signing key, workflow, deployment directory, or other seat's worktree was
  touched.

- 2026-08-04T12:10Z: the human-owned browser environment is not running, but its frozen Linux
  amd64 input package is now prepared and independently checkable. Eight new Zeus-only worktrees
  were created from the exact 11:04Z server/dashboard/five-plugin/index remote heads; every shared
  clone and other-seat worktree remained untouched. The current server cross-built as a static
  Linux amd64 binary. The five plugin UIs built offline and passed `verify:build`; both Linux
  runtime architectures rebuilt; deterministic packaging reproduced the existing signed manifest
  digests exactly: template `0a806be8`, vpn-core `89e4d484`, NetGuard `ac7e1d66`, WireGuard
  `decba2ac`, Sub-Store `9cc70651`. Plugin-index validation remained 1 accepted/7 rejected. The
  fresh dashboard build was not counted: the package-manager safety wrapper refused an unavailable
  registry-signature check before build. Instead the package reuses the already browser-proven
  static dashboard output from the exact same frozen dashboard commit `04c4046`; no different
  source or version was substituted. The private 106-file package contains server, dashboard,
  five official-publisher manifest/bundle pairs, index mirror, human-run loopback launcher, and
  SHA256SUMS; all entries verify and the final 34 MiB archive SHA-256 is
  `bb761caf0da1157428ea256312e19bb202b4be80eb092585fd9ddac3a1696d43`. It contains no credential,
  trust policy, publisher material, state, release tag or production config. Environment startup,
  transfer and SSH tunnel remain the operator's hands; eight proof worktrees remain registered
  until the browser matrix finishes. No signing, new artifact identity, release, workflow dispatch,
  remote host contact or deployment occurred.

- 2026-08-04T11:04Z: the first post-TASK-0018 verification freeze is now exact and read-only.
  Remote heads are Olympus main `2915d6755db26228c39e54184caa72388d8c63f5`; SDK
  `00943f6ec9e78f27f0dc18f1bc43c11decba4f8f`; server
  `1e6103001f16d48110bce471d68e6e638e805ada`; dashboard
  `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a`; node-agent
  `bbcc26c8fa271f3ae2f068ca10f2ed7b6d55372f`; template
  `a2e355b8c89c269ec479177a0e4e7820be288aeb`; vpn-core
  `74eb20c08d039dfa7e50729d74f646a5cb24251d`; NetGuard
  `22ea8e5a819df14cfe789e608a20041e8f2fcef4`; WireGuard
  `6ad14c76da3f1180599279564cfa75c11523edc2`; Sub-Store
  `3bf7bf5350ad2527665fbc66479e90ce0f5a47e8`; plugin-index
  `4ed4e5049eed77f76f91bee93a7c0c742c0fd310`; docs
  `e4ee963b72bfb95338e1381d871f0095d5361c5a`. This releases Athena's code-freeze blocker for
  TASK-0003/TASK-0004 browser evidence but is not a release candidate: the operator's isolated
  dev environment is not currently running, the prior proof server checkout predates the current
  server integration, and no new train artifact, version slot, signature, tag, release, workflow
  dispatch or deployment exists. The browser gate therefore needs one human-started fresh
  isolated environment before Chrome evidence can resume. Hephaestus has no open owned task after
  TASK-0019; a separate coordination letter offers TASK-0020 as a backend-only G3 remainder audit,
  leaving all UI and dangerous boundaries untouched.

- 2026-08-04T03:35Z: TASK-0017's exact acknowledged server tree landed on `integration` as
  `1e6103001f16d48110bce471d68e6e638e805ada`; the one authorized 20-minute full race-cover
  recovery returned zero, post-merge regression passed, and PR #27 is MERGED. The former server
  durability gate is therefore closed. The next honest train freeze now waits only for the
  release-bound plugin integrations to include TASK-0018's reviewed seed guards and for their
  owner acks; those `.gitignore` carries do not alter existing artifacts, signatures, manifests,
  or versions. After the six independent landings, Zeus can freeze exact current heads and draft
  the principal-only prerelease/sign/deploy checklist. No tag, signing, workflow dispatch, SSH,
  release, or deployment action occurred.

- 2026-08-03T10:36Z: concurrent-workspace audit found no active branch collision: Hephaestus's
  TASK-0017 server branch and Zeus's three TASK-0012 proof trees remain registered under their
  own `.wt/` paths, and no seat-owned tree was entered or changed. The shared code clones were
  inspected read-only. One historical exception is now explicitly quarantined:
  `lattice-plugin-index/` is clean but checked out on `feat/design-15-alpha-index` instead of
  `main`; Zeus did not switch or edit it, and any future train/index slice must use a fresh
  Zeus-owned worktree from the reviewed integration baseline. Existing unrelated dirty entries
  in shared clones were preserved. TASK-0012 is now closed with no residual browser evidence,
  while TASK-0017 r3 was returned for one restart-durability HIGH and Hephaestus has begun bounded
  r4 in his existing isolated server worktree. The next train snapshot remains correctly blocked
  until r4 is reviewed and merged; the operator has no release action to perform yet.

- 2026-07-31T14:11Z: a live read-only release snapshot across all twelve train repos proves
  there is no honest deployment candidate yet. The committed `v0.3.0-alpha.1` names server
  `c9c6710`, dashboard `8e6c206`, node-agent `03f730a`, SDK `00943f6`, and template artifact
  `v0.2.1-alpha.6`; current integrations are respectively `3fcf54a`, `04c4046`, `3e505d6`,
  unchanged `00943f6`, and `1def9f3` — 9/2/3/0/7 commits beyond those recorded inputs.
  Hephaestus's active TASK-0017 server branch is still at its clean `3fcf54a` base with no
  review head, so cutting before that security slice settles would make the manifest stale on
  arrival. The four non-template plugin integration heads still equal their signed prerelease
  tags and their GitHub releases are correctly marked prerelease, but `plugins.json` channels
  trail those train artifacts (vpn-core alpha.5 vs alpha.7; sub-store 0.3.2-alpha.4 vs
  0.4.0-alpha.2; netguard/wireguard alpha.7 vs alpha.9). Therefore the next legal sequence is:
  finish and review active integration work; freeze exact heads; select new prerelease slots;
  build and sign fresh artifacts; update the index; generate and validate a new prerelease
  train; then hand the principal a human-only release/deploy checklist. No stable-cut decision,
  tag, release, signing, workflow dispatch, SSH, compose, or deploy action was taken. The
  principal has nothing useful to execute until the frozen snapshot and artifacts exist.

- 2026-07-31T14:04Z: lattice#4 is MERGED on `origin/integration` as no-ff merge `cf93b9e`
  with first parent `4015f17` and exact reviewed second parent `e0f4354`. Before the ordinary
  non-force push, the remote base was proven unchanged; the merge tree equalled the reviewed
  feature tree. Fresh post-merge `make test`, `make build`, 5/5 clean-tree regression, shell
  syntax, ShellCheck, workflow YAML parse, and real five-repo `make check-clean` all passed;
  remote run `30635984550` was green on the exact reviewed head. The landing was recorded on PR
  #4, then all five clean Zeus TASK-0010 worktrees were unregistered and their parent removed;
  no other seat's worktree was entered or changed. Two orchestration artifacts were explicitly
  excluded from proof: one earlier long shell wrapper lost its session handle after timeout, and
  one remove/re-add shell continued from a cwd it had just removed; both left no stray process or
  wrong commit, and every affected validation/action was rerun successfully from a fresh process.
  The code repair gate is closed. TASK-0010 itself remains open only for a current validated train
  and the principal's stable-cut sign-off; the historical committed alpha train is not deployable.

- 2026-07-31T13:51Z: r2 at `cbf7091` closed both prior HIGHs, but Athena correctly withheld ack
  on two MEDIUM proof gaps: four isolated cases did not prove the loop reports every bad sibling,
  and gosec followed the supposedly final real gate. Pushed r3 `e0f4354` adds a fifth mixed scan
  containing clean + dirty + missing + non-repository inputs and requires all three failure paths
  in its output before the final nonzero result; regression is 5/5. The real five-repo gate now
  follows gosec as the workflow's literal last step. Fresh shellcheck, shell/YAML parse, diff check,
  post-commit real clean exit 0, and unchanged sum blob pass; remote CI and Athena r3 remain.

- 2026-07-31T13:36Z: Athena r1 returned two HIGH findings at the actual PR head: the review letter
  itself named a nonexistent object, and a failed `git status` was captured as empty output so a
  missing checkout passed `make check-clean`. Both were reproduced; the latter printed a fatal but
  exited 0. Replacement head `cbf7091` makes every inspection failure dirty and adds a CI-wired
  four-case regression: clean passes; dirty, missing, and non-repository fail with their named
  diagnostics (4/4). Fresh `make test`, `make build`, shellcheck, shell parse, YAML parse, diff
  check, an isolated missing-path exit 2, and the post-commit real five-repo clean exit 0 all pass;
  dependency trees are clean and the canonical sum blob remains `041fe6e3`. The branch is pushed;
  remote CI and Athena r2 are the remaining merge gates. One intermediate mixed-input probe also
  reported the intentionally dirty root, contradicting its predicted message count; it is
  explicitly invalidated and not used as evidence.

- 2026-07-31T13:15Z: the repair's remote `workspace` check completed SUCCESS at exact PR head
  `323e55d`; PR #4 remains draft, MERGEABLE/CLEAN, and intentionally unmerged until Athena's
  independent review. A read-only `git worktree list` audit across the active repos found no branch
  checked out by two seats: Zeus's five CI-layout trees are clean, Hephaestus has an isolated
  TASK-0016 server branch, and Athena's registered trees stay under Athena-owned paths. A remote
  `ls-remote` snapshot also proves the committed `v0.3.0-alpha.1` train is historical rather than
  deployable: its server/dashboard/node-agent commits predate current integration heads
  `0fef1eb`/`04c4046`/`3e505d6`. No release or deployment checklist can honestly be cut until the
  repair is reviewed and a fresh train is generated and validated.

- 2026-07-31T13:02Z: repair slice pushed as draft `lattice#4` at exact head `323e55d`, based on
  unchanged `integration@4015f17`. Root cause is the four moving default-branch sibling checkouts:
  an external module-graph change could rewrite this repo's tracked sum without a lattice event.
  The patch pins the exact previously resolved main heads, commits their canonical 10-line sum,
  adds a five-repo `make check-clean`, and wires it after test/build. Two full tests held the sum
  hash stable, build passed, 4/4 remote refs matched, clean exit was 0, and a planted SDK canary
  produced exactly one dirty-repo report plus exit 2 before clean restoration. The worktree was
  moved into the collision-free sibling layout `.wt/zeus-task0010-ci/lattice`; Athena r1 and
  remote CI are the remaining merge gates.

- 2026-07-31T12:49Z: the human release owner accepted the combined dirty-tree disposition:
  determine and repair the workspace pin/sum cause, then add a post-test clean-tree guard so a
  successful test cannot hide tracked generation. Implementation started in the Zeus-only
  `.wt/zeus-lattice-task0010-clean-tree` worktree on branch
  `fix/zeus-task0010-workspace-clean-tree`, based at `lattice origin/integration@4015f17`.
  Stable release approval remains separate and dangerous operations remain human-only.

- 2026-07-31T11:43Z: post-merge verification exposed a stable-cut readiness gap that the green
  workflow does not report. The isolated CI-layout `make test` exited 0 but changed tracked
  `go.work.sum` from 2 lines to 10; the current workflow does not assert a clean tree after tests.
  The temporary worktree and its modification were removed after the diff was inspected; no shared
  clone changed. This does not invalidate the docs-only merge, but TASK-0010 operator sign-off stays
  open until a separate reviewed slice decides whether to refresh the workspace sums, tighten the
  pins, and/or add a dirty-tree guard. No workflow edit or dispatch was performed in this round.

- 2026-07-31T11:34Z: slices 1 and 2 landed in their recorded order. lattice#3 was reviewed at
  exact head `680be3a`, received Athena r4 `[ack]`, and landed as the Olympus-required no-ff merge
  `4015f17` on `integration`; an isolated five-worktree CI layout then ran the original `make test`
  successfully without writing any shared clone. plugin-index#3 followed only after that landing,
  received Hephaestus r4 `[ack]`, reran `npm test` (1 accepted, 7 rejected), and landed as no-ff
  merge `a54bb9e` on `integration`. Both PRs are MERGED. No tag, release, signing, deployment, or
  workflow dispatch occurred. The task remains `in_progress`: only the human operator may sign off
  that the next stable cut can run from this, and the finish letter stays open until that decision.

- 2026-07-31T11:21Z: lattice#3 r4 is pushed at `680be3a`. The node-agent stable row now names
  `v0.2.9` with tag chronology/ancestry verified; the plugin→server edge distinguishes signed
  `compatibility.server` metadata, the optional signed `min_server` mechanism, and the absence of
  selected floors; the deployment observation cites the persisted Olympus field record. All five
  snapshot manifests, server validation semantics, and the deploy record were inspected;
  semantic assertions, `git diff --check`, independent r4 review `[ack]`, and GitHub workspace CI
  (`gofmt`, `make test`, `make build`, `gosec`) passed. Athena's formal r4 is the sole remaining
  train review gate; plugin-index#3 stays ready and ordered after it.

- 2026-07-31T11:04Z: Hephaestus returned the formal plugin-index#3 r4 `[ack]` with an
  independent 1 accepted / 7 rejected validator run and both planted counterexamples rejecting.
  The PR is ready, both checks are green, and its merge-base exactly equals current
  `integration@d64746e`. It remains intentionally unmerged until lattice#3 lands first, preserving
  the task's cross-repo docs-before-index order. Athena r3 is now the only release-train review
  response outstanding.

- 2026-07-31T10:52Z: review corrections are now pushed in both remaining code repos. lattice#3
  r3 is `dad071d`: the whole pin graph is an auditable `2026-07-27T14:53Z` snapshot, later
  versioned train artifacts are separated from snapshot-era `train.json` law, and validator
  claims are limited to structure/tag lanes/local cross-field invariants. `git diff --check`,
  five-component/zero-`min_server` inspection, independent review `[ack]`, and GitHub workspace
  CI passed; Athena's formal r3 remains the merge gate. plugin-index#3 r4 is `ab293d4`: server
  image tags are now server-only, the server lane is exactly `alpha-X.Y.ZaN`, 1 valid + 7 invalid fixtures pass,
  and both GitHub checks are green. Hephaestus's formal r4 remains its merge gate. No release,
  tag, deploy, signing, or workflow dispatch was performed.

- 2026-07-31T10:19Z: resumed from checkpoint with a read-only audit of every core/plugin/docs
  repo and registered worktree. The durable gaps are now explicit: lattice#3 remains open after
  athena's r1 findings were applied; plugin-index#3 remains open after hephaestus's r2 findings
  were applied; the first real train is committed on that branch but not merged. Established the
  missing `latticenet.github.io` integration baseline from its unchanged main tip, retargeted and
  merged docs#2 at `e4ee963b`, then re-ran `npm test` (site-content + VitePress build) and
  `check:pins` (1/1, node-agent latest stable `v0.2.9`) successfully. No release, tag, deploy, or
  workflow dispatch was performed. Final review requests are batched by letter; slice 3 was
  already co-signed/merged and its stale DoD box is corrected above.

- 2026-07-27T04:25Z: slice 2 SUBSTANTIALLY DELIVERED — format proposal ack'd (Decision A(b)
  closed, min_server implemented in server#22 MERGED); schema + zero-dep validator + example
  + CI shipped as plugin-index#3 (draft → integration), verified both directions (planted
  defects all caught). Remaining for slice 2: Decision B naming (operator; schema takes either
  answer) + first REAL train.json generated at the first coordinated cut. Slice 3 (rules/01
  §8.5 amendment) drafts after Decision B or after the 24h buffer with v0.3.0 default.
- 2026-07-26T12:40Z: slice 1 DELIVERED — `docs/contracts/release-pin-graph.md` on branch

- 2026-07-26T12:40Z: slice 1 DELIVERED — `docs/contracts/release-pin-graph.md` on branch
  `docs/zeus-task0010-pin-graph`, draft PR lattice#3 → integration. Every pin sourced; six
  gaps named (G1 no plugin→server min-version · G2 dashboard.ref lacks #9 until reconciliation
  + ref bump · G3 no single train artifact · G4 Astra/sing-box unpinned · G5 index
  hand-generated · G6 injected server version). Slice 2 next: release-manifest format proposal
  letter — must fold the F6 manifest-schema change into the SAME re-sign wave (one wave, not
  two). Merge of #3 awaits a second pair of eyes (no self-approve).
- 2026-07-26T12:30Z: claimed by zeus; starting slice 1. Home choice: the `lattice` design-docs
  repo (design docs are the contract there; the github.io mirror follows in slice 2 with the
  release-manifest format). `lattice` had no `integration` branch — created from `main` under
  the §7 branch-management grant, following the operator's own from-main precedent for the six.
  Branch: `docs/zeus-task0010-pin-graph`.
- 2026-07-26T12:06Z: created by zeus per operator ruling §1b; sliced so slice 1 (pin-graph
  documentation) depends on nothing.
