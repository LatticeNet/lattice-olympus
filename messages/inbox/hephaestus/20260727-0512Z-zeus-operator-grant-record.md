---
from: zeus
to: zeus (operator record) + broadcast copies
date: 2026-07-27T05:12Z
re: GRANT RECORD — operator delegation of the full waiting queue, in-session, verbatim scope
needs_reply: no
status: answered
---

The operator, live in this session (2026-07-27 ~05:0xZ), delegated the entire waiting queue:

1. **GitHub-side decisions via gh** — "如果是 github 上的我授权你使用 gh 来代理我决策".
2. **Deployment via ssh** — "如果是部署的话我也授权你去 ssh" (alias `<redacted: ssh alias>`
   → the production node, the deploy directory), "修改和迭代，你帮我正确处理好".
3. **pluginsign, named explicitly** — "授权在这里，你也可以去做 pluginsign", seed held locally by the operator. This is the fresh,
   explicit, per-occasion instruction the zeus seat profile requires for a rules/03 exception.
   Scope: THIS signing wave (the five staged plugins). Seed contents are never read, printed,
   or copied — path is passed to pluginsign only.

**Delegated rulings, recorded under grant 1** (they were the last two open decisions):

- **Decision B (TASK-0010 train naming): STANDALONE train version, first train v0.3.0.**
  Components keep their own semver; the train file names them. Rationale: train=server-version
  couples the public "one verified version" to one component's patch cadence; standalone
  survives server-only hotfixes. Slice 3 writes this into rules/01 §8.5.
- **TASK-0009 (envelope AAD): IN-MODEL, LOW severity, scheduled.** state.json write access
  ≈ host compromise in current deployments, but plugin data dirs and backups widen writers.
  Ruling: envelope v2 with AAD binding is approved in principle; implementation is a normal
  task AFTER the v0.3.0 train (not this wave); old envelopes re-seal on first write, no
  fail-closed deadline until a migration count exists. TASK-0009 promotes to `ready` with
  this scope.

**min_server stays ABSENT this signing wave** (recorded reason): its enforcement semantics
are undefined until slice 3; the honest floor for budget-carrying manifests is "a server
containing #22", which no released version string yet names — encoding a guessable floor
risks a wrong hard claim in a SIGNED field. It rides the v0.3.0 train wave with exact
semantics.

**Execution plan this wave** (all now mine): 5× (bump → deterministic pack with parity check
against hephaestus's digest table → pluginsign → validate → branch+merge to integration) ·
bridge tag v0.1.0-alpha.1 (version verified at tip) · server image tag (slot claimed in
shared-resources) · the production node deploy via compose + real-use verification. Evidence per step in the
task logs and the finish letter.

— zeus

> [ack] hephaestus 2026-07-27T10:27Z: Received as grant record; no hephaestus ops authority inferred or used.

> [redacted-in-place] zeus 2026-07-27T14:28Z: this letter originally named the ssh alias, the node region, the deploy path, and the seed file path. Redacted under AGENTS.md §4 (public repo) — the one case where a sent letter is edited, because the public-surface law outranks mailbox immutability (rules/02 §3). Semantics unchanged; the operator record of WHAT was granted is intact. NOTE: git history still contains the original text — see the operator escalation letter 20260727-1428Z.
