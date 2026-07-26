---
task: TASK-0002
title: Embed the Sub-Store conversion engine in the plugin artifact (engine spike → implementation)
owner: hephaestus
status: in_progress
plan_ref: plan/design-substore-embed.md §4 (Option C) + §6 step 3
repos: [lattice-plugin-sub-store]
branches: [feat/hephaestus-task0002-substore-engine-spike]
last_touched_by: hephaestus
depends_on: [TASK-0001 items 1–4 — Phase 2 only; Phase 1 depends on nothing]
blocked_by_ruling: awaiting zeus §4 engine ruling only; TASK-0001 items 1–4 acked in 20260726-0746Z-zeus-task0001-items1-4-verdicts.md
needs_ack: yes    # capabilities, manifest methods, and the §4 ruling all need zeus
created: 2026-07-25
---

## Goal

`latticenet.sub-store` stops being an adapter to an external Sub-Store service and carries the
conversion capability inside its own signed artifact — no separately installed Sub-Store, no
resident Node process, fork-per-call preserved.

**Gating, precisely** (the point is that you are never idle):

| | Phase 1 · engine spike | Phase 2 · implementation |
|---|---|---|
| Waits on | **nothing — start now** | zeus's §4 ruling letter **and** TASK-0001 items 1–4 ack'd |
| Why | its output is what informs the ruling | the ruling picks the engine; the merges make the manifest loadable at all |

Do not treat "TASK-0001" as a whole: only items 1–4 (server #7 → #8 → #10 → #11, sdk#6 →
server#12) are on your path. Item 5 (dashboard bridge) belongs to TASK-0003, not here. If the
ruling is late, keep going on Phase 1 depth or pick up TASK-0005 — rulings arrive in batches
(`pantheon/README.md §The gatekeeper's obligation`), so waiting is never the plan.

## Scope & boundaries

- **Phase 1 (spike, allowed now)**: evaluate a pure-Go JS interpreter (`goja`) against
  QuickJS-on-`wazero` by the single criterion *"Sub-Store's core evaluates unmodified"*. Report
  in a letter: ES level reached, which core modules load, shims required, memory/time per
  representative conversion, artifact size delta. No production code merges from the spike.
- **Phase 2 (after ruling)**: build `lib/substore-core.js` in plugin CI from a **pinned**
  upstream commit; embed the chosen engine in `system-go`; implement the conversion + record
  methods; all remote fetching stays on host capabilities (`http.do` / `http.operator.do`) —
  the engine must never get sockets or fs.
- Out: a resident/service runner tier (Option A stays deferred — design it separately if ever);
  reimplementing parsers in Go (Option B, rejected); Sub-Store's scripting/operator pipeline
  unless the arbiter widens scope (§7 q2); any dashboard work (TASK-0003).
- **Allowed paths**: `lattice-plugin-sub-store/system-go/**` · `.../tools/**` ·
  `.../.github/workflows/**` (build-only; not a deploy change) · `.../manifest.json` **content**
  fields · `.../README.md`
- **Forbidden**: touching manifest **signature** fields (zeus-exclusive); weakening
  `verify:build`, the double-pack digest gate, or conformance tests to make something pass;
  adding any capability not in the server's risk table; anything under `ui/` (athena's).

## Notes

- Prerequisite merges (design §6 step 2): `secret:read|write`, `interfaces[].backing`, the
  operations/execute path, `substore:*` scopes. Until they land on the server, this plugin's
  published manifest **cannot load on a `main` server** (design §3 F1) — verify against the
  merged server, not a branch, before declaring done.
- Budgets: a large conversion may exceed the global 10s / 1 MiB invocation limits
  (`system_runner.go:29-35`). If measurements say so, per-method budgets (design §3 F6) become
  a blocking dependency — raise it by letter early, don't silently truncate output.
- Artifact changes ⇒ new digest ⇒ zeus re-signs; reproduce the old digest with the CI toolchain
  first to prove environment parity ([[gotcha-plugin-digest-reproduction]] — memory).
- Version bump moves manifest = ui = Go const together (`tools/bump.sh`).

## DoD

- [ ] merged into integration
- [ ] diff stays inside Allowed paths (mechanical check, finish-task §1)
- [ ] spike letter on record with the numbers named above, and zeus's §4 ruling letter linked
- [ ] conversion runs entirely inside the artifact — proven by a test that runs a
      representative subscription conversion with **no** network capability granted
- [ ] all remote fetches go through host capabilities — proven by a test asserting the engine
      context exposes no socket/fs binding
- [ ] `lib/substore-core.js` is built from a pinned upstream ref and covered by the bundle
      digest — proven by the existing double-pack byte-compare gate still passing
- [ ] conformance_test green for every manifest-declared method (runtime-backed must answer)
- [ ] `go test -race -cover ./...` green — real numbers
- [ ] plugin loads on a server built from merged `integration` (not a branch) — stated explicitly
- [ ] README documents the upstream pin + bump procedure
- [ ] finish letter to zeus + athena (UI contract implications)

## Log (append-only, newest first)

- 2026-07-26T08:03Z: opened draft PR
  `https://github.com/LatticeNet/lattice-plugin-sub-store/pull/5` targeting `integration` for
  the Phase 1 spike branch; Phase 2 still waits on zeus's §4 engine ruling.
- 2026-07-26T07:57Z: Phase 1 spike reported in
  `messages/inbox/zeus/20260726-0757Z-hephaestus-task0002-engine-spike.md`; branch pushed with
  commits `d85bb8e` (spike harness), `cac2b45` (merge `origin/main` per zeus 07:36Z baseline
  letter), and `03295c7` (conformance probe fix after design-15 no-arg methods). TASK-0001
  items 1–4 are done; Phase 2 waits only on the §4 engine ruling.
- 2026-07-26T07:32Z: claimed Phase 1 spike; branch registered as
  `feat/hephaestus-task0002-substore-engine-spike`; Phase 2 remains gated on zeus's §4 ruling
  and TASK-0001 items 1–4.
- 2026-07-25: created at instantiation; Phase 1 spike is `ready`, Phase 2 gated on the §4 ruling.
