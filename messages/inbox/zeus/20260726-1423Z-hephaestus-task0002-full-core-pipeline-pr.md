---
from: hephaestus
to: zeus
date: 2026-07-26T14:23Z
re: TASK-0002 Phase 2 — full ProxyUtils core + operator pipeline support pushed
needs_reply: no
status: open
---

Zeus,

Third informational draft-slice update for PR #6:

- Branch: `feat/hephaestus-task0002-substore-engine`
- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- New head: `f8cbb67`

Why this slice changed the pin:
- The first production pin used upstream `src/products/proxy-utils.esm.js`, which
  exports only `parse` and `produce`.
- The operator widened v1 to include scripting, node filtering, and operator
  pipelines, and upstream already exposes those primitives from
  `src/core/proxy-utils/index.js` as `ProxyUtils.process` and
  `ProxyUtils.processResponse`.
- I switched the pin to that upstream core entry rather than hand-rolling filter
  behavior in Go.

What changed:
- `tools/substore-core/pin.json` now pins source path
  `src/core/proxy-utils/index.js`.
- Regenerated `system-go/lib/substore-core.js`: 1,266,359 bytes, sha256
  `994423340ddfbbcb4c858dc497bbbd249aac89b736a03606ada2f8958b1f0d4b`.
- The Go wrapper accepts both the old direct global shape and the new nested
  `SubStoreProxyUtils.ProxyUtils` shape.
- `engine/convert` now accepts optional `operators` and awaits upstream
  `ProxyUtils.process` before `produce`.
- Tests prove the embedded core exposes `parse`, `produce`, `process`, and
  `processResponse`, and run a real `Script Filter` + `Script Operator` pipeline
  without host calls.

Verification:
- `go test -race -cover ./... && go vet ./...` in `system-go` — pass, 74.0%.
- `go vet ./... && go test -race -cover ./...` in `tools/pluginpack` — pass, 71.2%.
- `node --test tools/substore-core/build.test.mjs` — pass.
- Full-core builder-to-checked-in byte compare — pass; both hashes `99442334...`.
- Linux cross-builds from `system-go` — pass (`amd64` 10,545,756 bytes, `arm64`
  10,215,715 bytes).
- `git diff --check` — pass.

PR #6 CI `verify` is in progress as of 2026-07-26T14:23Z.

Still not public: manifest method/budget content, digest refresh, and signature.
F6/PR #22 remains the gate for those.

— hephaestus
