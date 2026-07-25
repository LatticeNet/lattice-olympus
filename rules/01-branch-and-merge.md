# rules/01 · Branching, checkout & merging

Applies to all code repos `lattice-sdk · lattice-server · lattice-dashboard · lattice-node-agent · lattice (design docs) · lattice-plugin-{template, vpn-core, netguard, wireguard, sub-store, index} · latticenet.github.io · Astra (iOS client) · lr00rl/sing-box (fork)`. The Olympus repo itself commits straight to `main` (`AGENTS.md §4`).

---

## 1. Branch model

```
main                        ← stable baseline (release merges only; Integrator's hands)
└─ integration   ← ★ the ONE integration branch: all task branches land here
     ├─ feat/<handle>-task<NNNN>-<slug>
     ├─ fix/<handle>-task<NNNN>-<slug>
     └─ chore/<handle>-...
```

- One integration branch name across all code repos. Legacy branches get merged or declared dead at setup — never two live integration lines.
- One task (TASK-NNNN) = one same-named branch in every repo it touches.

## 2. Checkout (starting a task)

```bash
git fetch origin
git checkout -b feat/<handle>-task<NNNN>-<slug> origin/integration
```

- Always branch from the **fresh remote integration tip** — never from stale local branches or someone's feature branch.
- Need someone's unmerged work? Branch from integration anyway, then merge their branch (§6) and record the dependency in both task files.
- Rework returns to the original branch; never open a second branch for the same task.
- **Queued-resource dependencies**: if your `contract/shared-resources.md` claim builds on earlier *unmerged* numbers, don't develop on top of them in parallel — split the task so the dependent slice branches after its predecessors merge, or negotiate an earlier slot. Budget for exactly one final rebase (rules/02 §3.5); the field cost of ignoring this was four review rounds on a single task.

## 3. Push / pull rhythm

- **Push** your own task branch freely (backup + visibility); at least once per working day.
- **Pull** integration mid-task only when: a contract change lands · you're about to touch a shared file · the task exceeds 3 working days.
- **Never** rebase or force-push a branch that's been pushed.

## 4. Merge preconditions (all required)

1. `git fetch origin && git merge origin/integration` — resolve all conflicts **on your branch**;
2. Full tests green — report **real numbers**. Per-repo entries (mirror of each repo's CI):
   Go repos: gofmt-clean + `go vet ./...` + `go test -race -cover ./...` · dashboard:
   `pnpm test:navigation` + `pnpm type-check` + `pnpm build` · plugin UIs: `test` + `typecheck`
   + `build` + `verify:build` · plugin backends additionally run their conformance_test;
   exact entries in `memory/notes/map-<repo>`;
3. Task file updated + finish letter drafted (pushed together with the merge);
4. **Acks collected** (letter `[ack]` on record; word of mouth doesn't count) when touching:
   - anything in `contract/` → Contract Steward
   - files listed as someone's **exclusive** in their profile → that owner
   - shared files (profiles' shared lists) → the affected owner(s)
   - resources in `contract/shared-resources.md` → per the ledger
   - auth / permission / security semantics → Integrator
   - code you wrote inside someone else's authority area → that owner's review

## 5. The merge (task owner executes; multi-repo in sdk → server / dashboard / node-agent → docs site → plugins → plugin-index order)

```bash
git checkout integration
git pull --ff-only origin integration   # fails ⇒ polluted local branch → conflict prompt §3; NEVER force-push
git merge --no-ff feat/<handle>-task<NNNN>-<slug>  # --no-ff keeps the task boundary
# quick regression: run the repo's test entry once
git push origin integration
git push origin feat/<handle>-task<NNNN>-<slug>    # keep the branch for the record; prune periodically
```

Then push the Olympus side: finish letter + task status + status board.

## 6. Pulling someone's progress

| Case | Do |
|---|---|
| Already merged to integration (normal) | `git fetch origin && git merge origin/integration` |
| Need their **unmerged** branch | `git fetch origin feat/<them>-taskXXXX-* && git merge origin/feat/<them>-...` — **merge, never cherry-pick**; record dependency + send a letter |
| Just looking | `git fetch` then `git log/diff`, or a throwaway `git worktree add` |

## 7. Conflicts (procedure in prompts/conflict-and-integration.md)

1. Whoever merges, resolves.
2. Authority order: `contract/` > `plan/` & pantheon ownership > their task file & letters > code comments.
3. Conflict inside **someone else's exclusive area** → don't decide for them: keep their version, ask by letter; no ack, move your change elsewhere.
4. **Never** delete or comment out someone's tests/assertions to make a conflict go away.
5. Shared-resource collisions (migration numbers etc.): later merger renumbers and updates the ledger.
6. Record in the finish letter: conflicting files + whose semantics won + why.

## 8. Releases & main (Integrator / ops owner only, always by hand)

- Release from the integration branch; order `sdk → server / dashboard / node-agent → docs site → plugins → plugin-index`, rollback in reverse; data migrations additive only.
- CI triggers / deploy commands / infra: **the ops owner's hands**. Agents output a checklist ending with "Run this yourself".
- Verify by real use, not by "build passed". Broadcast the result in a letter; leftovers become tasks.
- At milestones the Integrator merges integration → `main` and tags.

## 8.5 Lattice branch, tag & version discipline (codified from field practice)

This section absorbs and extends the workspace-root `AGENTS.md` release law (which stays
authoritative for release mechanics; on conflict it wins for releases, this file wins for
branching).

**Branch layers.** `main` = stable baseline (default branch everywhere). `integration` = the
ONE standing integration branch, same name in every repo — created at setup from each repo's
`alpha/vX.Y.Z` tip where one exists, from `main` otherwise. Historical per-repo `alpha/vX.Y.Z`
branches are **retired legacy**: keep for the record, never develop on them, never create new
ones — version cuts are expressed by tags, not branch names. Also retired: long-lived feature
bases (`feat/lattice-vpn-core`) and `codex/<scope>-<date>` integration branches — the protocol
replaces both.

**Branch names.** New work: `feat|fix|chore|docs/<handle>-task<NNNN>-<slug>` (§1–2). This
extends the field's dominant `feat/<topic>` habit with owner + task traceability. Design-slice
context goes in the slug (`feat/hephaestus-task0007-design15-linemeta`).

**Commit style (code repos).** Current-era house style, no commitlint: **imperative,
sentence-case, outcome-framed subject; no type prefix, no scope**; body via a second `-m` when
the why isn't obvious. Examples on record: `Make Design 15 mutations honest from plan through
reconciliation` · `Prevent migration aliases from laundering delegated access`. English only.
Code commits ship with sibling docs commits (`Document …` / `Record …`) where behavior changed.
(The Olympus repo alone uses `[<handle>] <subject>` — AGENTS.md §4.)

**Tags — three lanes** (root AGENTS.md law):
- **Server deployment images**: `alpha-X.Y.ZaN` rapid train (e.g. `alpha-0.2.2a2`).
  `container.yml` is tag-driven — **pushing the tag IS the release trigger** (builds
  `ghcr.io/latticenet/lattice-server:<tag>`), so tag pushes are ops-owner-only (rules/03) and
  each `aN` slot is claimed in `contract/shared-resources.md` first. Never bump the base
  `X.Y.Z` inside a train; a floating `latest` tag exists — only the ops owner moves it.
- **Prerelease semver** everywhere else: `vX.Y.Z-alpha.N` (also `-beta.N`, `-rc.N`), published
  `--verify-tag --prerelease --latest=false` — a prerelease must NEVER become GitHub Latest;
  `target_version=latest` resolves to stable non-prerelease `v*` only.
- **Stable semver** `vX.Y.Z` cut from `main` at milestones, **only on an explicit
  operator-approved release decision** — never "because a build passed". Tags are immutable;
  a bad stable tag is marked prerelease/non-latest and documented, never deleted.
- **SDK**: stable-tags-only lane (v0.2.x, no prereleases); consumers pin Go **pseudo-versions**
  (`go get github.com/LatticeNet/lattice-sdk@<commit>`) between milestones; SDK pin updates
  land in the same slice as the change that needs them. Server pins `dashboard.ref` + `sdk.ref`
  SHAs; the About page must show matching versions before a deploy counts as complete.
- **Plugin versions**: manifest = ui = Go const move in lock-step (three places, one bump —
  `tools/bump.sh`); any artifact change ⇒ new digest ⇒ zeus re-signs the manifest; digest
  reproduction must use the CI toolchain (`GOTOOLCHAIN` pin technique — see memory). Plugin
  releases attach the signed binary + manifest.json as release assets.

**Draft-PR bridge.** Every task branch is pushed and opened as a **draft PR** targeting
`integration` (field practice: 100% of open PRs are drafts; branch-per-PR, 1:1). The PR is the
diff record and CI surface; merge preconditions and `[ack]`s still live in Olympus (letters,
rules/01 §4) — a green PR alone authorizes nothing. Mark the PR ready only after acks are on
record. Cross-repo changes reuse one branch/PR name across repos. When a task lands via the
integration branch rather than its own PR merge, close the PR **with a comment linking the
landing commit** — silent close-as-draft under-reports what shipped (known field wart).
Direct-to-main pushes (96 on record pre-Olympus, plus all of Astra) are over — Law 2.

## 9. Cheat sheet

```bash
# start
git fetch origin && git checkout -b feat/<handle>-task<NNNN>-<slug> origin/integration
# backup
git push origin HEAD
# absorb integration
git fetch origin && git merge origin/integration
# finish (tests green + acks in hand)
git checkout integration && git pull --ff-only origin integration \
  && git merge --no-ff <task-branch> && git push origin integration
```
