---
slug: map-lattice-dashboard
kind: map
keywords: lattice-dashboard, vue, vite, pnpm, PluginFrameHost, test:navigation, type-check
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Vue 3 + Vite + TS console (`@latticenet/dashboard`, pnpm). Key areas: `src/views/**` (incl.
`views/networking/GuardView.vue`, `WireGuardView.vue`, `PlanReviewDialog.vue`), plugin iframe
host `PluginFrameHost.vue` + `pluginFrameModel.ts` (sandbox/bridge — security semantics, zeus
ack), stores/composables under `src/`.
Test entry (mirror CI): `pnpm install --frozen-lockfile` → `pnpm test:navigation` →
`pnpm type-check` → `pnpm build` (vue-tsc --build && vite build). Dev: `pnpm dev` (port 5273).
Operator law: UI changes are verified in a real browser (Chrome connector), never by code
inspection alone — attach a manual test plan when headless E2E can't cover a flow.
Version lane: semver + `v0.2.2-alpha.N` prereleases; ships inside the server image via
`dashboard.ref`.
