---
slug: map-lattice-sdk
kind: map
keywords: lattice-sdk, model.go, proto, pseudo-version, Approval, NodeView, stable-only tags
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Go models + proto shared by server/agent/dashboard codegen. Key files: `model/` (`model.go` —
Approval typed binding columns, NodeInventory, netguard/WG models), `proto/**` (field numbers
are ledger resources — claim before adding; NodeView ≥28, ApprovalView ≥20 used).
Test entry: gofmt-clean → `go vet ./...` → `go test -race -cover ./...` (ci.yml).
Version lane: **stable-only tags** (v0.2.x, no prereleases); between milestones consumers pin
pseudo-versions via `go get github.com/LatticeNet/lattice-sdk@<commit>`; SDK pin updates land
in the same slice as the change needing them (root release law). Server CI stitches sdk+server
into a temporary go.work.
