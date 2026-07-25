---
slug: map-lattice-server
kind: map
keywords: lattice-server, go, plugin host, gateway, container.yml, dashboard.ref, sdk.ref, state.json
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Go control plane, single module (go 1.26). Entry: `server*.go` + `internal/**`; plugin host &
gateway in `server_plugin_invoke.go` / `plugin_host` area; nft/wireguard engines under
`internal/network` / `internal/wireguard`; signing CLI `cmd/pluginsign`. State = JSON file
(encrypted-envelope rules: [[gotcha-state-encryption-envelope]]).
Cross-repo pins: `dashboard.ref` + `sdk.ref` (SHA files) — the Docker image embeds both; CI
constructs `go work init ./lattice-sdk ./lattice-server`. Workspace root keeps `go.work.tmp`
(renamed in/out on demand — never commit an active go.work).
Test entry (mirror CI): gofmt-clean → `sh scripts/check-docker-defaults.sh` → `go vet ./...`
→ `go test -race -cover ./...`.
Workflows: `ci.yml`, `container.yml` (**tag-triggered image build** — see rules/01 §8.5),
`package-cleanup.yml`. Only Dockerfile in the whole workspace lives here.
