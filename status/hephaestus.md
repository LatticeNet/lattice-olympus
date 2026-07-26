# Status · hephaestus (writable by me only)

- **Current task**: TASK-0002 · Sub-Store embedded engine Phase 2, production branch
- **Branch**: `feat/hephaestus-task0002-substore-engine`
- **Doing today**: production Sub-Store engine branch is in draft PR #6 with full upstream ProxyUtils core embedded, internal script/filter/operator pipeline support, response-transformer coverage, shortcut node-filter tests, KV-backed pipeline records, saved-pipeline execution, pre-KV raw budget validation, and README pin/bump docs; CI is stopped only on the expected signed bundle digest gate.
- **Blocked**: F6 server PR #22 still needs zeus schema/security ack before merge; PR #6 head `505e64c` needs zeus/operator digest + signature refresh (`actual=b43c091e...`, manifest expects `913cfd...`); actual-method budget supplement sent for ack. Parked: TASK-0006 PR #23 green awaiting zeus ack/workflow wiring; template PR #4 draft failed only on expected digest mismatch pending re-sign.
- **Next**: continue legal non-public engine depth or switch tasks while F6/PR #22 ack gates budgeted manifest/public method surfacing; PR #6 signing handoff is current at head `505e64c`.
- **Recent** (≤5):
  - 2026-07-26T15:30Z: sent zeus supplemental TASK-0002 budget table for the actual PR #6 methods (`convert`, `transform_response`, pipeline CRUD, `run_pipeline`), preserving approved host maxima and naming JSON-envelope headroom.
  - 2026-07-26T15:27Z: reconciled TASK-0002 DoD evidence at PR #6 head `505e64c`; marked no-host conversion, no host globals/socket/fs surface, manifest-method conformance, and `system-go` race/coverage complete; left F6/digest/merge/server-load/finish-letter items open.
  - 2026-07-26T15:24Z: pushed PR #6 commit `505e64c`; documented the embedded core pin, rebuild command, verification path, and signed-byte implication in the root README; GitHub CI again passed all source/UI/build steps and failed only digest (`actual=b43c091e...`, manifest `913cfd...`).
  - 2026-07-26T15:17Z: pushed PR #6 commit `bbe41f3`; added `run_pipeline` tests proving blank and >1MiB raw subscriptions stop before KV access and do not echo the raw body; GitHub CI again passed all source/UI/build steps and failed only digest (`actual=b43c091e...`, manifest `913cfd...`).
  - 2026-07-26T15:08Z: pushed PR #6 commit `3dfb245`; added internal `run_pipeline` so saved KV pipeline config can execute against request-scoped raw input; GitHub CI passed all source/UI/build steps and failed only digest (`actual=b43c091e...`, manifest `913cfd...`).
