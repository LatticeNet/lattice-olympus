# plan/ · The charts (Lattice planning docs)

Revision rule (rules/04): finalized docs are never edited in place — amendments are new,
numbered files; on conflict, `contract/` wins.

## Docs in this directory

- `dev-history-2026.md` — development history digest through Olympus instantiation (2026-07-25).
- `design-substore-embed.md` — Sub-Store full-embed design (sidecar runtime + dashboard UI)
  plus the plugin-framework review that motivated it. Backlog source for TASK-0002/0003.

## Registered external plan docs (canonical design corpus)

| Doc | Where | Note |
|---|---|---|
| Architecture & design series (design-01…design-13, ADRs, Bundle V2 spec, §9.x plugin protocols) | `LatticeNet/lattice` repo, `docs/designs/` | canonical; design-13 = WireGuard+NetGuard plugin split |
| Working session plans / progress files / audit reports | operator's **private** planning archive (local `lattice_plan/`) | includes the 2026-07-14 plugin-boundary architecture review and fleet reports — private by policy (AGENTS.md §4) |
| Draft-PR backlog | GitHub, LatticeNet org (draft PRs across 9 repos + sing-box fork) | inventoried by TASK-0001 |

## Backlog at instantiation (task-splittable)

1. Draft-PR review sweep → TASK-0001 (zeus).
2. Sub-Store embed: sidecar-capable plugin host + embedded engine → TASK-0002 (hephaestus);
   dashboard UI surface → TASK-0003 (athena).
3. NetGuard G3–G7, WireGuard W3–W5 + Phase 4 migration (design-13 phases; tasks cut when claimed).
4. `jump_edges` producer (server) — unblocks topology relay edges.
5. Alpha-train inclusion decisions for WebAuthn / Lines / Sidebar / Inventory features (zeus + operator).
6. Fleet hardening rollout — gated on NetGuard maturity; details private.
