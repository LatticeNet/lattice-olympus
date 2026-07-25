---
slug: decision-plan-digest
kind: decision
keywords: plan digest, backlog, division of labor, 60 30 10, alpha train, substore, netguard, wireguard
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Working sessions read THIS, not the plan docs. State at instantiation (2026-07-25):

1. **Seats, not people**: hephaestus (runtime Codex CLI, principal zeus) ~60% — Go backend;
   athena (runtime Kimi CLI, principal zeus) ~30% — frontend/docs; zeus (principal self,
   runtime human + Claude Code) ~10% dev + 100% gating + orchestrator. Both agent seats are
   `gated_by: zeus` for auth/plugin-gateway/secrets scope. Seats are rarely online together →
   letters not chat, and every task must be resumable by another seat (`prompts/handoff.md`:
   where · done · verified · next · dead ends). The gatekeeper owes batched rulings and must
   split any gating task on a higher-share seat's path — TASK-0001/0007 exist for that reason.
2. **Branch/tag law**: `main` stable · `integration` = the one integration branch everywhere
   (legacy per-repo `alpha/v*` retired) · task branches `feat/<handle>-task<NNNN>-<slug>` ·
   server images `alpha-X.Y.ZaN` (tag push = release, zeus-only) · prereleases
   `vX.Y.Z-alpha.N --prerelease --latest=false` · stable `vX.Y.Z` needs explicit operator
   approval · SDK pinned by pseudo-version between milestones · commit style: imperative
   sentence-case outcome subjects, no type prefixes. Full text rules/01 (+§8.5).
3. **Plugin law**: signed manifests, per-service `backing: runtime|core`, conformance gates,
   §9.3 plan→approve→execute, §9.4 secret storage. [[decision-plugin-backing]]
4. **Active lanes**: TASK-0001 critical-path review, 8 PRs (zeus) · TASK-0002 Sub-Store engine
   embed, Phase 1 spike unblocked (hephaestus) · TASK-0003 its UI (athena) · TASK-0007 the rest
   of the backlog (zeus, blocks nobody); design in plan/design-substore-embed.md.
5. **Next big rocks**: NetGuard G3–G7, WireGuard W3–W5 + Phase 4, jump_edges producer,
   alpha-train inclusion of shipped-but-unmerged features.
6. **Public-repo rule**: no internal hosts/ports/fleet posture here — operator's private notes.
