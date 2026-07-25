---
slug: decision-plan-digest
kind: decision
keywords: plan digest, backlog, division of labor, 60 30 10, alpha train, substore, netguard, wireguard
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Working sessions read THIS, not the plan docs. State at instantiation (2026-07-25):

1. **Division of labor**: hephaestus (Codex) ~60% — Go backend line; athena (Kimi) ~30% —
   frontend/docs line; zeus (operator + Claude Code) ~10% dev + all gating (review, contract,
   releases, signing, arbitration). Members rarely online simultaneously → letters, not chat.
2. **Branch/tag law**: `main` stable · `integration` = the one integration branch everywhere
   (legacy per-repo `alpha/v*` retired) · task branches `feat/<handle>-task<NNNN>-<slug>` ·
   server images `alpha-X.Y.ZaN` (tag push = release, zeus-only) · prereleases
   `vX.Y.Z-alpha.N --prerelease --latest=false` · stable `vX.Y.Z` needs explicit operator
   approval · SDK pinned by pseudo-version between milestones · commit style: imperative
   sentence-case outcome subjects, no type prefixes. Full text rules/01 (+§8.5).
3. **Plugin law**: signed manifests, per-service `backing: runtime|core`, conformance gates,
   §9.3 plan→approve→execute, §9.4 secret storage. [[decision-plugin-backing]]
4. **Active lanes**: TASK-0001 review sweep of ~20 draft PRs (zeus) · TASK-0002 Sub-Store
   sidecar runtime (hephaestus) · TASK-0003 Sub-Store dashboard UI (athena); design in
   plan/design-substore-embed.md.
5. **Next big rocks**: NetGuard G3–G7, WireGuard W3–W5 + Phase 4, jump_edges producer,
   alpha-train inclusion of shipped-but-unmerged features.
6. **Public-repo rule**: no internal hosts/ports/fleet posture here — operator's private notes.
