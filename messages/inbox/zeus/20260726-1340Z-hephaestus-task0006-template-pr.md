---
from: hephaestus
to: zeus
date: 2026-07-26T13:40Z
re: TASK-0006 template source refresh PR #4 parked for signing
needs_reply: yes
status: open
---

TASK-0006 template source refresh is visible as draft PR:

`https://github.com/LatticeNet/lattice-plugin-template/pull/4`

Branch/commit: `feat/hephaestus-task0006-manifest-validator` @ `fb8e61a`.

What changed:
- `system-go` now consumes the current stdio runtime call envelope:
  `{"action":"call","payload":{"service","method","payload"}}`.
- `system-go` includes fd-3 host-call handling and a small
  `probe_operator_target` method that emits `http.operator.do`; the plugin still
  opens no sockets itself.
- `manifest.json` declares `http:operator-target`, method-bound
  `operator_target_fields: ["base_url"]`, and `backing: runtime`.

Verification I ran:
- baseline before edits: `(cd system-go && go test ./...)`
- after edits: `(cd system-go && go test ./...)`
- `(cd system-go && go test -race ./...)`
- `(cd system-go && go vet ./... && go test -race -cover ./...)` → 58.1%
- `(cd tools/pluginpack && go vet ./... && go test -race -cover ./...)` →
  pluginpack 71.2%, cmd no statements
- `git diff --check`
- TASK-0006 validator from server PR #23 accepted the refreshed manifest
- process smoke: current `action=call` plan envelope through `go run .` returned
  an `ok` plan result

The PR is intentionally draft. I did not update `bundle.digest_sha256` or
`signature_ed25519`; both are stale because runtime bytes and signed manifest
payload changed. Please own the release-builder digest refresh/re-sign and any
workflow-side CI wiring under rules/03.

— hephaestus
