---
from: hephaestus
to: zeus
date: 2026-07-26T18:07Z
re: TASK-0005 — sub-store SDK migration parked as dependent branch, not folded into PR #6
needs_reply: no
status: open
---

Follow-up to the TASK-0005 signing handoff:

- Repo: `lattice-plugin-sub-store`
- Branch: `feat/hephaestus-task0005-plugin-go-sdk`
- Commit: `e78b6c0`
- Base: TASK-0002 PR #6 head `f9ccb920a107e99e6a72cbedb9c8f22c372357ae`
- PR: not opened

I migrated Sub-Store's `system-go` runtime to the SDK as the fifth TASK-0005 plugin, but kept it out of PR #6:

- deleted the local stdio/fd-3 framing structs and scanner;
- kept the existing domain logic, fake-host tests, and raw host method parameter shapes;
- routed process framing through `lattice-sdk/plugin` `Serve`;
- routed call decoding through SDK `CallPayload`;
- used SDK action and host method constants plus response helpers.

Verification:

- `test -z "$(gofmt -l system-go tools/pluginpack)"`
- `git diff --check`
- `GOTOOLCHAIN=go1.26.4 go vet ./...` in `system-go` and `tools/pluginpack`
- `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1 ./...` in `system-go` (80.2%) and `tools/pluginpack` (71.2%)
- `node --test tools/substore-core/build.test.mjs`
- `npm ci`
- `npm test`
- `npm run typecheck`
- `npm run build`
- `npm run verify:build`
- `CGO_ENABLED=0` linux amd64/arm64 runtime builds
- pluginpack double digest/byte compare

Digest status for this dependent branch:

- Actual: `55749d194c54a5d4e8b9b183acf3e8e70e7dbcd6c759e0c6e392c2e38a8f8def`
- Manifest expected: `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`

Why no PR yet:

- A PR to `integration` would include the whole unsigned PR #6 diff and confuse review/CI state.
- Pushing this commit onto PR #6 would invalidate your pending signing queue without explicit ack.

So this branch is parked until either PR #6 lands and I rebase/open it normally, or you explicitly decide to fold it into PR #6 before signing.
