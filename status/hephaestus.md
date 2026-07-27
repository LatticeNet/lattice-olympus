# Status · hephaestus (writable by me only)

- **Current task**: TASK-0002, TASK-0005, and TASK-0006 are merged; checking the remaining hephaestus queue
- **Branch**: merged heads — server `c9c67107`; sdk `00943f6e`; template `85f4e24f`; vpn-core `3b8949f3`; wireguard `857b7d58`; netguard `e1547813`; sub-store `b5f6fc8`
- **Doing today**: closed the signing/deploy/CI follow-through, co-signed TASK-0010 train law, and merged the `tools/bump.sh` alignment fix in vpn-core and sub-store.
- **Blocked**: none in the just-closed queue.
- **Next**: Touch, verify whether TASK-0008 has a remaining merge/ack action, then pick the next legal hephaestus-owned item or stop if the mountain is quiet. Monitor remains `hephaestus-olympus-monitor` (log `/private/tmp/hephaestus-olympus-monitor/events.log`).
- **Recent** (≤5):
  - 2026-07-27T10:27Z: closed TASK-0002/TASK-0005/TASK-0006 after Zeus/operator signing, HKG deploy verification, and released-server CI gate success x5; sent finish letters to Zeus and Athena.
  - 2026-07-27T10:25Z: fixed `tools/bump.sh` alignment matching in vpn-core (`3b8949f3`, PR #6) and sub-store (`b5f6fc8`, PR #8). Full local verification passed: vpn-core system-go 75.0%, pluginpack 71.2%, UI 13/13; sub-store system-go 80.3%, pluginpack 71.2%, UI 12/12.
  - 2026-07-27T04:54Z: added SDK-era `TestManifestInterfacesAreServedAsDeclared` to template/vpn-core/wireguard/netguard integration after verifying old #2 PR conformance tests had not made it across. Pushed test-only heads `eff0bc4`, `5a65752`, `8ee86b2`, `71a3be8`; focused conformance, vet, race/cover, gofmt, diff-check passed; closed stale PR #2 in those repos.
  - 2026-07-27T04:34Z: pushed integration merges after Zeus 04:12Z ack batch: template `92f470f`, vpn-core `7a992ff`, wireguard `695170a`, netguard `d82f598`, sub-store `ed92baa`. Local post-merge gates passed; PR comments written; GitHub reports the PRs as already merged. Wireguard/netguard also gained required `backing: core` manifest declarations after the merged server validator rejected missing backing.
  - 2026-07-26T18:06Z: pushed sub-store TASK-0005 dependent branch `feat/hephaestus-task0005-plugin-go-sdk` at `e78b6c0`, based on PR #6 head `f9ccb92`; no PR opened to avoid confusing the integration diff while PR #6 awaits signing. Local full checks passed; dependent digest `55749d19...`.
