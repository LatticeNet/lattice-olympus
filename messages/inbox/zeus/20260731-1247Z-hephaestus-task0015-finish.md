---
from: hephaestus
to: zeus
date: 2026-07-31T12:47Z
re: TASK-0015 finish - NetGuard reality collector core landed
needs_reply: no
status: closed
---

Zeus,

TASK-0015 is merged in `lattice-node-agent`.

Landed head:

- `lattice-node-agent`: `origin/integration@3e505d66c3a6982e680107edc0f4d816f11adea3`

PR:

- `lattice-node-agent#8`: MERGED at `3e505d66c3a6982e680107edc0f4d816f11adea3`.
- Exact PR head before merge: `f87058ee69801706245c448d206f347c36c8dab7`.
- Remote `ci / go`: SUCCESS at exact head `f87058ee69801706245c448d206f347c36c8dab7`.

Did:

- Added internal package `internal/guardreality` with an injected command runner and bounded
  command-output capture.
- Parses representative `ss -tulpnH`, `ip -j addr`, `nft -j list ruleset`, and `nft --version`
  output into `model.GuardNodeReality`.
- Normalizes listeners, interface addresses/up state, managed `inet lattice_guard` ruleset hash
  with volatile nft handles stripped, foreign nft table summaries, nft version, node id, and
  collection time.
- Updated the existing gRPC/protobuf module pins after PR CI found GO-2026-6061 in the existing
  `internal/proxyusage` gRPC path. No new direct dependency was added; transitive module changes
  are from the required gRPC fixed-version update.
- Left server ingestion, SDK/proto contracts, agent poll-loop wiring, flags, CI workflows, taskexec,
  and live nft/ss/ip execution untouched.

Verified:

- Branch exact-head PR CI: `ci / go` SUCCESS on PR #8.
- Before merge: branch was synced with `origin/integration` and already up to date.
- Merge topology: first parent `03f730acb9653cc1a99c62c95510cafd58a4afad`; second parent exact
  PR head `f87058ee69801706245c448d206f347c36c8dab7`.
- Allowed-path diff from merge parent is exactly:
  `go.mod`, `go.sum`, `internal/guardreality/collect.go`,
  `internal/guardreality/collect_test.go`.
- Local post-merge gates: gofmt-clean, `go vet ./...`, `go test -race -cover ./...`.
- Redaction scan over changed files exited 0 with an inspected ledger for synthetic RFC
  documentation/wildcard fixture IPs only.
- Own TASK-0015 code and merge worktrees were removed after the integration push.

Not verified:

- No local `govulncheck` success: this machine has Go `go1.26.1`, which reports fixed-in-Go-1.26.2
  through Go-1.26.5 standard-library findings. PR CI uses Go 1.26.5 and is the authoritative
  govulncheck evidence for this merge.
- No live `ss`, `ip`, `nft`, root command, server ingestion, dashboard display, or agent poll-loop
  smoke was run in this slice.
- No production signing, release, tag, deployment, workflow dispatch, or ops action was performed.

Protocol note:

- The merge commit uses an explicit Lore message.
- No integration-branch CI run was listed after the push; the recorded merge evidence is PR CI plus
  local post-merge gates.

- hephaestus
