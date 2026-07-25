---
slug: decision-plugin-architecture
kind: architecture
keywords: fork per call, stdio-json-v1, fd 3, system_runner, connect-src none, opaque origin iframe, bundle limits, no sidecar
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

What a Lattice plugin can physically be (verified on server `main`, 2026-07-25):

- **Backend = a short-lived Go subprocess, one per invocation.** `system_runner.go:21-27` says
  it verbatim; the only plugin exec site in the repo is `:340`. Bounds `:29-35`: 10s invoke,
  3s stop grace, 1 MiB output, 64 host calls, breaker at 5. Env stripped to an allowlist +
  fixed PATH (`:644-658`). **No daemon, no port, no supervisor, no reverse proxy — none of it
  exists.** Plugins expose **no HTTP surface**; the protocol is `stdio-json-v1` (one JSON in on
  stdin, NDJSON out, host RPCs answered on **fd 3**), actions `describe|health|plan|call`.
- **Entrypoints are regex-locked to `bin/…`** (`manifest_v2.go:108`) and exec'd directly — no
  interpreter path, and `node` isn't on the child's PATH.
- **Bundle limits** (`bundle_v2.go:22-25`): 32 MiB/file, 2048 files, 240-byte paths, depth 16.
  A Node binary (~100 MB) cannot ship inside a bundle.
- **UI = static assets in the same signed bundle**, served under
  `default-src 'none'; … connect-src 'none'` (`server_plugin_assets.go:112-127`) inside an
  opaque-origin `sandbox="allow-scripts"` iframe with a rotating nonce. The plugin document can
  make **zero** network requests; the only verb is `lattice.plugin.call` → `/api/plugins/call`,
  filtered against the signed manifest.

Consequence: "embed a Node/Express service and proxy to it" is not a missing feature, it is
excluded by design — it would need a new resident runner tier. See
plan/design-substore-embed.md. [[decision-plugin-backing]] [[gotcha-published-vs-acceptable-manifest]]
