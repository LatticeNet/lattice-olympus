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
repo, for ~9 hours. **The gap was never the prose; it was that nothing checked.** So run the
check before any push to this repo — and then keep reading, because the check cannot see
everything.

```sh
git diff --cached -U0 | grep -nEi \
  'ssh +[a-z0-9._-]+@|[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,}|[0-9]{1,3}(\.[0-9]{1,3}){3}|\
/(opt|srv|var/lib)/[a-z]|/(Users|home)/[a-z]|\
\.(pem|key|seed|p12|pfx|kdbx)\b|id_(rsa|ed25519|ecdsa)|\
(private[_-]?key|BEGIN [A-Z ]*PRIVATE KEY)|/(secrets?|keystore|credentials)/|\
\.env([^a-z]|$)|_authToken|Authorization: *(Bearer|Basic)|\
(ghp|gho|ghs|ghu)_[A-Za-z0-9]{16,}|github_pat_[A-Za-z0-9_]{20,}|\
xox[baprs]-|AKIA[0-9A-Z]{12,}|sk-[A-Za-z0-9]{16,}'
```

**Two properties of this check, both load-bearing:**

1. **A hit is stop-and-inspect, not an automatic block.** `127.0.0.1`, `example.com`, a
   documentation path, and a token-shaped example are all legitimate. Read the hit; decide.
2. **A clean run is NOT permission to push.** The check catches shapes — command forms, path
   families, token prefixes, address literals. It is blind to the class that actually leaked
   first: a **bare local alias or node label sitting in prose**, which looks like an ordinary
   word. Nothing mechanical will reliably separate `the-turin-box` from `the-quick-fix`. So a
   clean grep satisfies nothing on its own — `AGENTS.md §4` still binds every internal host
   name, node label, local alias, deploy path, and credential location, and the author is
   still the one who has to know they wrote one.

Deliberately category-based: the patterns name *kinds* of secret material (private keys, env
files, token prefixes, credential directories), never this fleet's actual names or paths —
a rule that has to be redacted to be published is not a rule anyone can use.

Redact to meaning, never to silence: "the production node", "the deploy directory", "the
operator-held seed file" carry the sense without the target.

**Redacting a tip does not redact history.** A leak that reached a push is a leak; the tip fix
is hygiene, and whether history gets rewritten is the operator's call alone (rules/03 —
irreversible). Say so plainly in the escalation rather than implying the problem is gone.
