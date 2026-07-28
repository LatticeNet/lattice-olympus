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

## Pre-push redaction check (a floor, never a waiver)

The public-surface rule (`AGENTS.md §4`) already listed hostnames, ssh aliases, IPs, and secret
paths when they leaked anyway on 2026-07-27 — from the ops owner's own letters, into a PUBLIC
repo, for ~9 hours. **The gap was never the prose; it was that nothing checked.**

```sh
rules/checks/redaction-scan.sh          # staged diff (run before every push)
rules/checks/redaction-scan.sh FILE...  # specific files
```

**It is a script, not a command in prose, and that is the point.** The first two published
versions of this check were both broken — one had `\b` inside a group, the next had shell
line-continuations inside a single-quoted pattern — and the second failure was the dangerous
kind: grep exited 2 and printed **nothing**, which is indistinguishable from a clean run to an
author following the rule literally. A transcribed command is a copy that rots silently; a
committed script can be tested, and is:

- `rules/checks/redaction-fixture.txt` — one line per category with its expected HIT/MISS
- `rules/checks/test-redaction-scan.sh` — asserts every expectation; run it after any edit

**Three distinguishable outcomes** (verified, not asserted):

| Exit | Meaning | What you do |
|---|---|---|
| `1` | findings printed | Stop and inspect each. A hit is not automatically a block — `127.0.0.1`, `example.com`, a documentation path and a token-shaped example all hit legitimately. |
| `0` | no pattern hits, said out loud | Keep reading below. |
| `2` | **the scanner itself is broken** | Fix the scanner before pushing. It self-tests against a canary so it can never fail quietly. |

**A clean run is NOT permission to push.** The scan catches shapes — command forms, path
families, token prefixes, address literals. It is blind to the class that actually leaked
first: a **bare local alias or node label sitting in prose**, which looks like an ordinary
word. Nothing mechanical will reliably separate `the-blue-crate` from `the-quick-fix`. So exit
0 settles nothing on its own — `AGENTS.md §4` still binds every internal host name, node label,
local alias, deploy path, and credential location, and the author is still the one who has to
know they wrote one. (An earlier draft of this very paragraph used an illustration built from a
real node label's distinctive token — inside the rule that forbids exactly that. Caught at
co-sign. Illustrations here must be words with no relationship to anything deployed.)

Patterns name *kinds* of secret material, never this fleet's actual names or paths: a rule that
has to be redacted before it can be published is not a rule anyone can use.

Redact to meaning, never to silence: "the production node", "the deploy directory", "the
operator-held seed file" carry the sense without the target.

**Redacting a tip does not redact history.** A leak that reached a push is a leak; the tip fix
is hygiene, and whether history gets rewritten is the operator's call alone (rules/03 —
irreversible). Say so plainly in the escalation rather than implying the problem is gone.
