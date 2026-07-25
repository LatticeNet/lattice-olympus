---
slug: map-lattice-umbrella-docs
kind: map
keywords: lattice repo, design docs, ADR, design-13, design-15, latticenet.github.io, pages
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Two documentation repos:
- **`lattice`** (umbrella): `docs/designs/design-NN-*.md` (design-13 WG+NetGuard plugin split;
  design-15 line identity / per-line user writes / chain recognition / Sub-Store integration),
  ADRs (ADR-004 vendored gRPC client for sing-box per-user stats), `docs/superpowers/specs|plans/`
  working specs. CI `ci-integration` runs gofmt over sdk/server/agent + `make test` + `make build`.
  Design docs are the contract: new subsystem work starts by writing/amending a design here.
- **`latticenet.github.io`**: public docs site, `pages.yml` deploy (deploy = ops owner).
  Release-discipline and download-security pages mirror rules — keep in sync when rules change
  (doc DoD, rules/04).
