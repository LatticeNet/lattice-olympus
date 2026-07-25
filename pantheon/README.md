# pantheon/ · Hall of the Gods (member registry)

One profile per collaborator — **human or agent**. This is the sole authority on identity, permissions, and division of labor; `AGENTS.md §0` and `rules/03` both point here.

## Member table (maintain by hand on join/change)

| Handle | Epithet | Principal | Runtime | Share | Roles | Domain (one line) | Branch prefix | Danger ops | Gated by |
|---|---|---|---|---|---|---|---|---|---|
| `zeus` | Zeus, bearer of lightning | self (the operator) | human + Claude Code | ~10% | integrator+orchestrator+ops+steward+arbiter | core decisions, verification, backlog routing, releases, signing | `feat/zeus-*` | **yes — sole holder (human hands only)** | — |
| `hephaestus` | Hephaestus, master of the forge | zeus | Codex CLI | ~60% | developer+reviewer | Go backend: server / sdk / node-agent / plugin backends / sing-box fork | `feat/hephaestus-*` | no | zeus (auth · RBAC · plugin gateway · approvals · secrets · signed artifacts) |
| `athena` | Athena, weaver of strategy | zeus | Kimi CLI | ~30% | developer+reviewer | frontend & docs: dashboard / plugin UIs / docs site, bilingual passes | `feat/athena-*` | no | zeus (plugin iframe sandbox · bridge contract · anything auth-facing) |

> Shares are routing guidance, not quotas. Seats are **rarely online at the same time**, so the
> async letter/status protocol is the coordination backbone — and every task must stay resumable
> by another seat (`prompts/handoff.md`).

## Seats, principals, and runtimes

A row above is a **seat**, not a person and not a model. Three things can differ per seat:

| Field | Meaning | Why it matters |
|---|---|---|
| `principal` | the **human accountable** for the seat (`self` if a human works it directly) | accountability never belongs to a runtime; the ops owner's "by hand" only means something because a human stands behind that seat |
| `runtime` | what actually does the typing — a specific agent CLI, or "human only" | routing and verification depth; a seat can change runtime without changing identity |
| `share` | rough expected share of hands-on work | lets the orchestrator balance the backlog; guidance, never a quota |

**Heterogeneous teams are the normal case.** Runtimes differ in context size, tool access, quota, and how literally they follow procedure. The protocol absorbs that by design:

- **Procedure lives in files, not in an agent's head** — that is why prompts are re-pasted every session and why the task file (not the chat) is the contract;
- **Route by domain first, capability second** — give heavy implementation to the seat with the biggest share, and give *smaller slices* to a seat with a tighter context or a weaker instruction-following record;
- **Verification depth scales with distance from the gate, not with brand trust** — what a seat produces is gated by `gated_by` and by `rules/01 §4`, identically for every runtime;
- **A seat may pair a human with an agent** (e.g. `zeus` here). Then say so in the profile: which decisions the agent may draft, and which are only final once the principal confirms them in the session.

## Role vocabulary (one person may hold several)

| Role | Duty | Count |
|---|---|---|
| **Integrator** | integration-branch health, verification, conflict arbitration | ≥1 |
| **Ops Owner** | the only one who executes dangerous ops (**by hand**; agents draft at most) | ideally 1 |
| **Contract Steward** | drafts and gates `contract/` | 1 |
| **Orchestrator** | keeps the backlog `ready` and routed: creates/splits tasks, assigns owners by domain, share, and slice size; hands the baton when a seat stalls | ≥1 (often the same seat as Integrator) |
| **Developer** | claims tasks, delivers vertical slices | N |
| **Reviewer** | cross-line code review (usually mutual) | N |
| **Arbiter** | final call on rule disputes (must be human in pure-agent teams) | 1 |

## The gatekeeper's obligation (this mountain's asymmetry)

`zeus` holds ~10% of the hands-on share but gates 100% of the output. That is deliberate, and it
is also the mountain's likeliest stall. Two standing mitigations, binding on the gatekeeper:

1. **Batch the rulings.** Decisions that only the principal can close (architecture forks,
   scope questions) are answered in batches, not one round-trip each. A seat that needs a ruling
   letters it and **keeps working** on a pre-authorized slice — never idles waiting.
2. **Never gate a large share behind a large task.** A gating task on the critical path is split
   until the blocking part is small (see TASK-0001 vs TASK-0007). If a 60%-share seat is waiting
   on a 10%-share seat, that is a routing bug for the orchestrator to fix, not a queue to accept.

## Profile rules

1. Filename = handle: `pantheon/<handle>.md`; lowercase; the handle is also the branch prefix, inbox directory, and commit prefix.
2. **Only the member (and their agent) edits their own profile**; role/permission changes need the Arbiter's ack (letter on record).
3. Onboarding: copy `_template.md` → fill → add a row above → create `messages/inbox/<handle>/` and `status/<handle>.md` → first bootstrap.
4. Code-ownership matrices live inside each profile. **Two profiles claiming the same file exclusively = config error** — letter to the Arbiter on sight.
5. `gated_by` is a **cross-cutting gate**: whoever it names must `[ack]` your merges in that scope even inside your exclusive paths (typical scope: auth, permissions, secrets, release artifacts). State the scope in the profile's boundaries section.
