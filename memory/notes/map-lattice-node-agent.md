---
slug: map-lattice-node-agent
kind: map
keywords: lattice-node-agent, taskexec, singbox stats, release.yml, compat-json, install integrity
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Go agent: sandboxed task executor (`taskexec` — sh/bash/python3/node, cgroups,
no-new-privileges, non-root) polling the server over HTTPS; helpers `--selfcheck-controlplane`,
`--update-nft-domain-set`; design-15 adds a read-only sing-box stats collector via vendored
gRPC proto (`singboxdiscover` resolves outbound tag → downstream server:port).
Layout: `cmd/`, `internal/`, `scripts/`.
Test entry (mirror CI): gofmt-clean → `sh scripts/check-release-workflow.sh` →
`sh scripts/test-install-integrity.sh` → `go vet ./...` → `go test -race -cover ./...`.
Release: `release.yml` on `v*` tags (goos/goarch matrix). `lattice-agent -version` is the exact
update target; compatibility metadata via `-compat-json`; `target_version=latest` resolves to
stable non-prerelease only (root release law).
