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

**One permanent, expected hit**: `rules/checks/redaction-fixture.txt` trips the scan by
construction — it is a page of deliberately-matching lines. Any commit touching it will report
findings; inspect and proceed. Its contents are documentation-reserved addresses (RFC 5737 /
`example.org`) and fake tokens, nothing real. Do not "fix" the fixture to quiet the scan; that
is disarming the only thing that tests it.

Patterns name *kinds* of secret material, never this fleet's actual names or paths: a rule that
has to be redacted before it can be published is not a rule anyone can use.

Redact to meaning, never to silence: "the production node", "the deploy directory", "the
operator-held seed file" carry the sense without the target.

**Redacting a tip does not redact history.** A leak that reached a push is a leak; the tip fix
is hygiene, and whether history gets rewritten is the operator's call alone (rules/03 —
irreversible). Say so plainly in the escalation rather than implying the problem is gone.

## Pre-push native Lore check

Lore fields are optional, but a field that is written must be a native Git trailer. Blank lines
between fields make Git parse only the final paragraph; passing literal `\\n` text through a
commit command can make Git parse none of them. Before every Olympus push, after the required
fetch/rebase pair, run:

```sh
rules/checks/lore-commit-scan.sh refs/remotes/origin/main..HEAD
```

The script scans every outbound commit, counts physical line-start fields, literal escaped fields
and native parsed fields by **name and multiplicity**, and prints `commits_scanned=N
violations=N`. Checking only `HEAD`, or comparing only aggregate counts, is insufficient. Its
independent harness is `rules/checks/test-lore-commit-scan.sh`.

| Exit | Meaning | What you do |
|---|---|---|
| `0` | every outbound commit is native-clean | continue with redaction review and the other push gates |
| `1` | one or more malformed commit objects | stop; follow rules/01 §3.2 — later prose does not repair the objects |
| `2` | range, Git command or scanner failed | fix the scanner/input before any push |

There is deliberately no SHA allowlist and no "corrected, therefore green" mode. A known malformed
object remains malformed forever. If concurrent shared-main work has already built later commits
on it, the additive correction record and principal-only exact-range ruling in rules/01 §3.2 are
the one bounded incident path; they do not change the scan result.

## Verifying a check: say the number first

One review thread (2026-07-27/28) produced this, repeatedly: **a check reported success while
doing nothing.** The instances, enumerated rather than counted — a section about honest numbers
should not rest on a headcount, and the first draft of this one miscounted itself three ways:

| # | Instance | Fault lay in | Caught by |
|---|---|---|---|
| 1 | `\b` inside a group — the command errored out | the check | its author's smoke test |
| 2 | shell line-continuations inside a quoted pattern: exit 2, **no output** | the check, as published | a reviewer running the published block instead of reading it |
| 3 | ledger parsed a list bullet as a snippet; `grep` error swallowed; every finding emptied and success printed | the check | its author, running it on a real diff |
| 4 | a one-character ledger entry waived the whole scan **and printed the success line** | the check | a reviewer |
| 5 | an injected "malformation" that was valid syntax — the guard was never exercised | the test | its author, on re-measurement |
| 6 | a control diffing a revision that did not exist → empty input → exit 0 | the test | a number predicted in advance that did not match |
| 7 | exit status read through a pipe — **twice, hours apart, by both parties, after this lesson was written down** | the measurement | taking the bare measurement alongside it |
| 8 | a harness inheriting an exported variable, waiving a case that must always fire | the test's environment | local and CI disagreeing |
| 9 | CI scanning a narrower range than the push, after a fallback quietly narrowed it | the check's input | a reviewer reproducing it in a real clone |
| 10 | a test whose input was derived from the constant it tested — it could only ever confirm | the test | breaking the guard it protected and watching nothing go red |
| 11 | an edit script that failed to parse, so **nothing changed** — and the suite passed, because nothing had changed | the work, not the check | an error printed *above* the green |
| 12 | eight intended Lore fields were separated into paragraphs; native Git parsed only the last one | the commit construction and the missing pre-push object check | predicting 8, then measuring 1 with `git interpret-trailers --parse` |
| 13 | a commit command stored literal `\\n` text; prose claimed a native check, but Git parsed 0 of 7/8 fields | the commit construction and an unverified verification claim | scanning the full outbound range after the malformed commit was no longer `HEAD` |

Different mechanisms, one shape: **the thing measured sat adjacent to the thing claimed, and
success was the default appearance.** Row 11 is the sharpest variant: the success signal was
entirely *honest* — the suite really did pass the state it was given. What had not happened was
the work. Re-reading caught none of them. Every one was caught by a
number that contradicted an expectation, or by running the artifact instead of reasoning about
it.

1. **Write the expected number before you run it** — "3 added lines, exit 1" — then run it. A
   result you did not predict cannot surprise you.
2. **Treat a surprise as the test being wrong until proven otherwise.** Rows 5, 6 and 8 were the
   harness, not the subject; row 6 was caught *only* because a number had been committed to
   first.
3. **Measure exit codes on the bare command.** `cmd | tail` reports the pipe's status — row 7,
   twice, by people who had just recorded the lesson.
4. **Make every check print a count** — findings, expectations met, commits scanned, entries
   waived. A check that prints only on failure cannot be told apart from one that is broken.
5. **Test a guard by breaking the thing it guards** — and check that your breakage is real
   (row 5 is what happens when it is not).

This applies to every check here: validators, CI steps, conformance probes, the redaction scan.
It is not about diligence. Every row above was produced by someone being careful, immediately
after writing down the previous row.
