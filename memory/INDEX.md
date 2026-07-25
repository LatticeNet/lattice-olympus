# Memory Index

> One line per note; this file is read at every session start. Format: `- [slug](notes/slug.md) — hook`.

- [decision-plan-digest](notes/decision-plan-digest.md) — read this instead of the plan docs: lanes, laws, division of labor
- [decision-git-conventions](notes/decision-git-conventions.md) — branch/tag/commit/PR law on one screen
- [decision-plugin-architecture](notes/decision-plugin-architecture.md) — fork-per-call stdio model, CSP-locked UI: what plugins can and cannot be
- [decision-plugin-backing](notes/decision-plugin-backing.md) — backing runtime|core ruling, conformance gates, §9.3/§9.4
- [decision-webauthn-rpid](notes/decision-webauthn-rpid.md) — RPID only from LATTICE_PUBLIC_URL, 503 fail-closed
- [gotcha-plugin-digest-reproduction](notes/gotcha-plugin-digest-reproduction.md) — artifact change ⇒ digest ⇒ re-sign; CI toolchain pin
- [gotcha-state-encryption-envelope](notes/gotcha-state-encryption-envelope.md) — new State collections silently plaintext unless wired ×3
- [gotcha-rbac-empty-nodeid](notes/gotcha-rbac-empty-nodeid.md) — why plugins declare no node-scoped interfaces
- [gotcha-published-vs-acceptable-manifest](notes/gotcha-published-vs-acceptable-manifest.md) — signed sub-store manifest can't load on main server
- [map-lattice-server](notes/map-lattice-server.md) — control plane, plugin host, tag-triggered images, ref pins
- [map-lattice-dashboard](notes/map-lattice-dashboard.md) — Vue console, plugin iframe host, browser-verify law
- [map-lattice-sdk](notes/map-lattice-sdk.md) — models/proto, field-number ledger, pseudo-version lane
- [map-lattice-node-agent](notes/map-lattice-node-agent.md) — task executor, sing-box stats, release matrix
- [map-lattice-umbrella-docs](notes/map-lattice-umbrella-docs.md) — design docs are the contract; canonical spec location
- [map-plugin-repos](notes/map-plugin-repos.md) — uniform plugin layout; sub-store, not template, is the reference
- [map-astra-singbox](notes/map-astra-singbox.md) — iOS client + sing-box fork peculiarities
