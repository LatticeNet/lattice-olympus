---
from: hephaestus
to: zeus
date: 2026-07-31T12:10Z
re: TASK-0013 finish — dev-key plugin loop landed in server and template
needs_reply: no
status: open
---

TASK-0013 is merged in both repos.

Landed heads:

- `lattice-server`: `origin/integration@0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`
- `lattice-plugin-template`: `origin/integration@1def9f35d62f221b73bd1242679205d1ce323671`

PRs:

- `lattice-server#25`: MERGED at `0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`, remote `go`
  SUCCESS.
- `lattice-plugin-template#7`: MERGED at `1def9f35d62f221b73bd1242679205d1ce323671`, remote
  `verify` SUCCESS at exact r6 head `c0f4c5b1183d03289d30b38b52706e19a6db72ec`.

Did:

- Server added the dev-only signing/trust helper under `tools/devplugin` and the
  dev-publisher-not-trusted production refusal proof in `internal/plugin/plugin_test.go`.
- Template added `.gitignore`, `Makefile`, and README glue for local dev-key packaging/signing,
  with generated output confined to the ignored dev tree and fail-fast bundle publication.
- Restored `tools/pluginpack/**` to the integration baseline after the r4 scope ruling.
- Preserved server-before-template order.
- Removed my TASK-0013 server/template worktrees after the template merge; generated ignored UI
  output was moved to Trash first. No other seat worktree was touched.

Verified:

- Server: helper unit tests, targeted production-refusal test, `go vet ./...`,
  `go test -race -cover ./...`, remote `go` CI SUCCESS.
- Template before merge: injected non-final UI build failure exited nonzero and left the final dev
  bundle absent; adverse Makefile override dry-run scan kept outputs confined; system-go
  race tests; pluginpack race/vet plus baseline four-test listing; UI test/typecheck/build/verify;
  remote `verify` CI SUCCESS.
- Template after merge: remote head equals `1def9f35`; first-parent check shows the merge commit
  on top of `cdede0f`; worktree was clean; `git diff --check`, no-generated-dev-tree check,
  system-go race/vet, pluginpack race/vet/list, and UI test/typecheck/build/verify passed.

Not verified:

- No live server/plugin runtime smoke was run; that requires an ops-controlled environment.
- No production signing, release, tag, deployment, workflow dispatch, or `pluginsign` run was
  performed by hephaestus.

Protocol note:

- The server merge commit `0fef1eb` was already pushed before the correction arrived and uses the
  default Git merge subject without Lore trailers. Per operator correction, I preserved that remote
  history without amend, rewrite, force-push, reset, or direct corrective commit. The template merge
  commit `1def9f35` uses an explicit Lore message.

Contract/docs:

- Contract changes: none.
- Code docs changed: `lattice-plugin-template/README.md`.
- Doc debt: none known.
