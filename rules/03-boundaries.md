# rules/03 · Boundaries (the most important law)

One sentence: **dangerous operations belong to the pantheon's **ops owner**, executed by that human's hands only; no agent ever executes them.** Zeus may write no code — but the lightning never leaves his hand.

---

## 1. Dangerous operations (agents never execute — no exceptions)

| Category | Examples (Lattice stack — widened, never narrowed) |
|---|---|
| Orchestration | any docker / docker compose / kubectl / helm subcommand against a deployed host or fleet node — including "read-only" `ps`/`logs`; banned wholesale to keep the line bright |
| Releases | **pushing any git tag matching `alpha-*` or `v*`** (lattice-server `container.yml` is tag-driven — a tag push IS a release trigger); GitHub Actions re-runs/dispatch; ghcr.io image push; editing anything under `.github/workflows/` outside zeus's branch flow |
| Servers | ssh / scp / rsync to any fleet node (every fleet ssh alias and raw node IP); cloud instance start/stop/resize; VM console access |
| Network | Cloudflare DNS / proxy / certificates; reverse-proxy config & reload; **applying WireGuard or nftables plans to live nodes**; editing sing-box configs on nodes (`/etc/sing-box/**`) |
| Data | writing prod `state.json` or plugin data dirs on deployed hosts; deleting or altering backups (`*.bak.*`); bulk operations on live nodes via `task:run` |
| Secrets | the publisher ed25519 seed in the operator's local keystore (read, copy, or **any `pluginsign` invocation**); LATTICE_* env secrets; PATs, TOTP/WebAuthn state; creating, rotating, or pasting any credential |
| Irreversible | force-push; deleting remote branches/tags; migration rollback; GitHub org/repo administration; node re-provisioning |

Keep the principle when extending: **ban wide, never narrow**. Permissions an agent acquires "just to look" become incidents later.

## 2. Per-side rules

**The ops owner's agent:**
- May: draft commands, checklists, release steps, rollback plans; analyze logs the owner pastes in; edit infra *code* as normal code (branch flow; applying stays human).
- Must: stop after every drafted command with, prominently:
  > **Run this yourself** — agent does not execute:
- Never: actually execute, for any reason; never hide a dangerous call inside a script and then run the script.

**Every other agent:**
- **Zero contact**: no executing, no drafting, no editing deploy/CI/infra files.
- Need an environment, a release, logs, a config? → letter to the ops owner (task id, what, why), then switch tasks per rules/02 §4. No idling.

## 3. Release skeleton (the ops owner executes by hand)

1. Integration branch green; relevant TASKs merged;
2. Release in `sdk → server / dashboard / node-agent → docs site → plugins → plugin-index` order; rollback in reverse;
3. Smoke-check by **real use**, not "build passed";
4. Broadcast the result in a letter + update your status board; leftovers become tasks.

## 4. Why this strict

- An agent's failure mode with dangerous ops isn't "error" — it's *quietly succeeding at the wrong thing*;
- The minimal audit unit is "which human approved this execution" — agent-run commands erase it;
- Collapsing execution to one person minimizes coordination: everyone just remembers "ask the ops owner".
