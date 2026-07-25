# pantheon/ · Hall of the Gods (member registry)

One profile per collaborator — **human or agent**. This is the sole authority on identity, permissions, and division of labor; `AGENTS.md §0` and `rules/03` both point here.

## Member table (maintain by hand on join/change)

| Handle | Epithet | Roles | Domain (one line) | Branch prefix | Danger ops | Privileges |
|---|---|---|---|---|---|---|
| `zeus` | Zeus, bearer of lightning | integrator+ops+steward+arbiter | core decisions, verification, orchestration, releases, signing (~10% dev, 100% gating) — human operator + Claude Code | `feat/zeus-*` | **yes — sole holder (human hands only)** | contract authority, release, manifest signing |
| `hephaestus` | Hephaestus, master of the forge | developer+reviewer | Go backend: server / sdk / node-agent / plugin backends / sing-box fork (~60% dev) — Codex CLI | `feat/hephaestus-*` | no | — |
| `athena` | Athena, weaver of strategy | developer+reviewer | frontend & docs: dashboard / plugin UIs / docs site, bilingual passes (~30% dev) — Kimi CLI | `feat/athena-*` | no | — |

> Workload split by design: hephaestus ~60%, athena ~30%, zeus ~10% hands-on + all gating.
> Members rarely work simultaneously — the async letter/status protocol is the coordination
> backbone, not real-time chat.

## Role vocabulary (one person may hold several)

| Role | Duty | Count |
|---|---|---|
| **Integrator** | integration-branch health, verification, conflict arbitration | ≥1 |
| **Ops Owner** | the only one who executes dangerous ops (**by hand**; agents draft at most) | ideally 1 |
| **Contract Steward** | drafts and gates `contract/` | 1 |
| **Developer** | claims tasks, delivers vertical slices | N |
| **Reviewer** | cross-line code review (usually mutual) | N |
| **Arbiter** | final call on rule disputes (must be human in pure-agent teams) | 1 |

## Profile rules

1. Filename = handle: `pantheon/<handle>.md`; lowercase; the handle is also the branch prefix, inbox directory, and commit prefix.
2. **Only the member (and their agent) edits their own profile**; role/permission changes need the Arbiter's ack (letter on record).
3. Onboarding: copy `_template.md` → fill → add a row above → create `messages/inbox/<handle>/` and `status/<handle>.md` → first bootstrap.
4. Code-ownership matrices live inside each profile. **Two profiles claiming the same file exclusively = config error** — letter to the Arbiter on sight.
