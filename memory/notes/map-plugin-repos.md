---
slug: map-plugin-repos
kind: map
keywords: plugin template, vpn-core, sub-store, netguard, wireguard, plugin-index, system-go, manifest, bump.sh, verify
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Six plugin repos share one layout: `system-go/` (backend, own go.mod; conformance_test probes
every manifest method) · `ui/` (Vue, scripts `build`/`test`/`typecheck`/`verify:build`) ·
`tools/` (`bump.sh` syncs the three version sites, `pluginpack/`) · `manifest.json` (signed;
per-service `backing: runtime|core` — [[decision-plugin-backing]]). CI job `verify`.
- **template**: reference implementation incl. §9.3 execute flow; also `wasm/`, `worker/`,
  `SECURITY.md`. Copy from here, don't invent.
- **vpn-core / netguard / wireguard**: core-backed façades (backing: core, 9 services).
- **sub-store**: runtime-backed adapter (endpoint vault, import preview, drift detection);
  full-embed design in plan/design-substore-embed.md.
- **plugin-index**: `plugins.json` + validator (`pnpm check` / `test`); alpha channels are
  explicit opt-in; publisher key rotation recorded here.
Version lock-step + digest/re-sign law: [[gotcha-plugin-digest-reproduction]].
