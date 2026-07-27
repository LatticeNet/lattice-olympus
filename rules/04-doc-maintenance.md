# rules/04 · Documentation

Principle: **docs travel with code, state travels with Olympus, design travels with plan/contract.** Never mix the three.

| Kind | Lives in | Maintainer | When |
|---|---|---|---|
| Code docs (README, module design, API notes) | each code repo | module owner per pantheon | **same branch, same commit** as the code; behavior changed but docs not = merge precondition fails |
| State / progress / letters | this repo: status/ tasks/ messages/ | each their own | task boundaries |
| Design / rules / contract | this repo: plan/ contract/ rules/ | Contract Steward, co-signed | **docs first, then code** |

## Revising plan/

Finalized plans are never edited in place; revisions are new, numbered files stating what they amend. On conflict, **contract/ wins over plan/** — the contract is runtime truth, the plan is a snapshot.

## Per-task doc DoD

The finish letter lists: ① code docs changed ② contract changes triggered (link the changelog row) ③ any doc debt — named explicitly and turned into a chore task, never silent.

## Style for agents

Consistent vocabulary (glossary in plan/); no "should work" / "mostly done" — state did / verified / not verified; verify that every command, path, and endpoint you write actually exists.

## Pre-push redaction check (mechanical, not aspirational)

The public-surface rule (`AGENTS.md §4`) already listed hostnames, ssh aliases, IPs, and secret
paths when they leaked anyway on 2026-07-27 — from the ops owner's own letters, into a PUBLIC
repo, for ~9 hours. **The gap was never the prose; it was that nothing checked.** So: before
any push to this repo, run the check, not your memory.

```sh
git diff --cached -U0 | grep -nEi \
  'ssh [a-z0-9_-]*@|[0-9]{1,3}(\.[0-9]{1,3}){3}|/opt/[a-z]+/|_authToken=[^$]|\.seed|/Users/|/home/[a-z]'
```

Any hit is a stop-and-think, not an automatic block — `127.0.0.1` and an example path are
fine, a fleet alias is not. Redact to meaning, never to silence: "the production node", "the
deploy directory", "the operator-held seed file" carry the sense without the target.

**Redacting a tip does not redact history.** A leak that reached a push is a leak; the tip fix
is hygiene, and whether history gets rewritten is the operator's call alone (rules/03 —
irreversible). Say so plainly in the escalation rather than implying the problem is gone.
