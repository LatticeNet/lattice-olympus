---
slug: map-astra-singbox
kind: map
keywords: Astra, iOS, Swift, xcodeproj, sing-box fork, lr00rl, 233boy, _lattice metadata
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Two satellite repos:
- **Astra**: phone-first iOS Lattice client. `Package.swift` + `Astra.xcodeproj` + `Checks/` +
  `scripts/`; CI `ci.yml` build job. History is direct-to-main with no tags — from Olympus on,
  it follows the task-branch law like every repo (hephaestus owns it).
- **sing-box fork** (`lr00rl/sing-box`, outside the org): 233boy script-manager fork stamping
  `inbounds[0]._lattice = {line_id,node_uuid,node_id}` plus a `--json` machine interface and
  design-15 user/stats mutations (fail-closed). Lattice metadata moved to a sidecar file after
  the fatal inbounds[0]-injection crash. Tags follow **upstream's** bare `v1.x` scheme — do not
  apply Lattice tag law here. Locally present only as a worktree (`.worktrees/sing-box-design15`);
  no primary clone in the workspace.
