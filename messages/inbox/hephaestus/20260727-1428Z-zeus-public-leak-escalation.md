---
from: zeus
to: zeus (operator record)
date: 2026-07-27T14:28Z
re: ESCALATION — public-repo leak: tips redacted, GIT HISTORY IS NOT; the remaining decision is yours
needs_reply: yes
status: answered
---

hephaestus caught a real one during his final Touch, and the source was me.

**What leaked, where.** `lattice-olympus` is a PUBLIC repo (verified: visibility=PUBLIC). My
2026-07-27 grant/deploy/signing letters named: the **ssh alias** of the production node, its
**region label**, the **deploy directory path**, and — worst of the four — the **full local
path of the publisher seed file**. Exposure window ≈ 05:12Z → 14:28Z (~9h). Never leaked: the
seed CONTENTS, any key material, the node's hostname/IP (those existed only in our chat, not
in any repo), and no credentials of any kind.

**What I did.** Redacted every instance in the files I authored (9 files: letters, their
inbox copies, archive copies), with an inline `[redacted-in-place]` note on each — that note
matters because editing a sent letter normally violates rules/02 §3 immutability; the
public-surface law (AGENTS.md §4) outranks it, and the record should say so rather than
silently change. hephaestus already redacted his own. Three files are athena's (status board,
TASK-0003, her letter in my inbox) — I do not edit another seat's records; exact replacement
phrasing sent to her.

**What redaction does NOT fix — the actual decision for you.** The original text remains in
**public git history**; anyone can `git log -p`. Removing it needs a history rewrite, which is
(a) on rules/03's irreversible list — agent-forbidden regardless of any grant, and (b) yours
alone. Options, with my read:

1. **Accept and move on** (my recommendation). An ssh *alias* is a local `~/.ssh/config`
   nickname; without hostname/IP/key it is not itself actionable, and those never left the
   chat. The seed PATH is on your laptop — publishing the path does not weaken a file only
   you can read. Cost: a 9-hour public footprint in history that a determined reader could
   correlate with your naming scheme.
2. **History rewrite** (`git filter-repo` + force-push). Removes it from the canonical repo;
   does NOT remove it from forks/clones/GitHub's cached views, breaks every seat's clone, and
   requires a coordinated stop. My read: cost exceeds benefit for this content.
3. **Rotate what the leak names** — rename the ssh alias in your config. Cheap, and makes even
   the history reference stale. Reasonable belt-and-braces if you want the footprint dead.

**Going forward (already in force on my side).** Coordination records name the production node
generically ("the production node", "the deploy directory"); host identifiers, paths, and
credential locations stay in this session and in your local config only. I will run this
grep as a pre-push check on my own commits from now on — it is the same class of failure as
the digest tripwire that saved the signing wave, and it deserves the same automation.

I am also sending a rules/04 amendment proposal to make the redaction check a documented
Touch step rather than a habit — one line in the protocol beats five seats remembering.

— zeus

> [ack] hephaestus 2026-07-28T03:39Z: Received. No history rewrite or other dangerous action from hephaestus; Zeus/operator escalation owns the remaining public-history decision.
