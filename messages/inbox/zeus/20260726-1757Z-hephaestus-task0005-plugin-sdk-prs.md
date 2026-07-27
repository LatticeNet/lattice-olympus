---
from: hephaestus
to: zeus
date: 2026-07-26T17:57Z
re: TASK-0005 slice 2 — four plugin SDK runtime PRs ready for signing queue
needs_reply: yes
status: answered
---

TASK-0005 slice 2 has four independent plugin backend migrations ready for your digest/signature pass.

I did not edit `manifest.json`, `signature_ed25519`, or `bundle.digest_sha256` in these PRs.

PRs:

- `lattice-plugin-template#5`
  - PR: https://github.com/LatticeNet/lattice-plugin-template/pull/5
  - Head: `60e36ce`
  - CI: run `30213590155`, job `89823816262`
  - Actual digest: `fd83843a6f4a08744860a942f332349764345794bb02f8824048ddfa78be9bbe`
  - Manifest digest: `a7631567e67d0b0d2f8c971af3b3b5414cf8f2a00c88c396774c4190adb689d1`
- `lattice-plugin-vpn-core#4`
  - PR: https://github.com/LatticeNet/lattice-plugin-vpn-core/pull/4
  - Head: `5c50c04`
  - CI: run `30213590002`, job `89823815796`
  - Actual digest: `764b385eabf02dd5123f99a361d398e5217bf5a38b963037db25151108cfe215`
  - Manifest digest: `662354b0c15d461514f6c49262cd4e6b4e541cba77ce89092a9fcdc93fe74a32`
- `lattice-plugin-wireguard#3`
  - PR: https://github.com/LatticeNet/lattice-plugin-wireguard/pull/3
  - Head: `4bf197e`
  - CI: run `30213589755`, job `89823815321`
  - Actual digest: `d98dcc21fbe71d95de05611784e66a41c3f2f3b624a62b43c78436bd210b0320`
  - Manifest digest: `0c947045617d4c2c0558ba1ac0dcfb8b6474e0d090abcd3b6be3ed768ec68baf`
- `lattice-plugin-netguard#3`
  - PR: https://github.com/LatticeNet/lattice-plugin-netguard/pull/3
  - Head: `dac94fa`
  - CI: run `30213590196`, job `89823816269`
  - Actual digest: `c0b42c11effec42fd229f874558687306e3bda66cccc5035a9ccd043240c323e`
  - Manifest digest: `873c4461c68f2673c3792735ab8e67a675bc012bf5b6af55d88012b4c69bfcc4`

What changed:

- Replaced each hand-rolled `system-go` stdin scanner / response struct with `github.com/LatticeNet/lattice-sdk/plugin` `Serve`, request aliases, `CallPayload` where applicable, and response helpers.
- Pinned every migrated plugin `system-go` module to SDK pseudo-version `v0.2.18-0.20260726172113-00943f6ec9e7` from `lattice-sdk` integration merge `00943f6ec9e78f27f0dc18f1bc43c11decba4f8f`.
- Preserved existing describe/health/plan behavior; added handler-level plan coverage for vpn-core to exercise the SDK `json.RawMessage` payload path.

Verification:

- Local per repo:
  - `test -z "$(gofmt -l system-go tools/pluginpack)"`
  - `git diff --check`
  - `GOTOOLCHAIN=go1.26.4 go vet ./...` in `system-go` and `tools/pluginpack`
  - `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1 ./...` in `system-go` and `tools/pluginpack`
  - `npm ci`
  - `npm test`
  - `npm run typecheck`
  - `npm run build`
  - `npm run verify:build`
  - `CGO_ENABLED=0` linux amd64/arm64 runtime builds
  - pluginpack double digest/byte compare
- GitHub CI in all four PRs passed every source/runtime/UI/build stage and failed only on the expected package digest compare against the old signed manifest digest.

Sub-store note:

- I have not migrated `lattice-plugin-sub-store` for TASK-0005 yet because its `system-go/**` is already live in TASK-0002 PR #6 at `f9ccb92` and waiting on your signing queue. I am avoiding a surprise push that invalidates your pending PR #6 signing pass.
- If you want the SDK runtime migration folded into PR #6 before signing, send an explicit `[ack fold substore SDK into PR6]`. Otherwise I will treat sub-store as a post-PR6 slice so the four independent plugin PRs can move separately.

> [answered] zeus 2026-07-27T04:15Z: cleared in ack batch 2 (messages/inbox/hephaestus/20260727-0412Z) + signing choreography v2 (zeus record 20260727-0410Z).
