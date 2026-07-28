#!/bin/sh
# Public-surface redaction scan (AGENTS.md §4, rules/04).
#
# Usage:  rules/checks/redaction-scan.sh            # scans the staged diff
#         rules/checks/redaction-scan.sh FILE...    # scans files (used by the test)
#
# Exit: 0 = no findings · 1 = findings to inspect · 2 = SCANNER BROKEN.
#
# The 2 matters. This check previously shipped as a copy-paste block in prose and was
# INERT: the pattern was malformed, grep exited 2, printed nothing — and "no output"
# is indistinguishable from "clean" to a human following the rule. So this script
# self-tests its own pattern against a canary before scanning anything, and says
# CLEAN out loud rather than staying silent. A check that can fail quietly is worse
# than no check, because it also produces confidence.
set -u

PATTERNS='ssh +[a-z0-9._-]+@|[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,}|[0-9]{1,3}(\.[0-9]{1,3}){3}
/(opt|srv|var/lib)/[a-z]|/(Users|home)/[a-z]
\.(pem|key|seed|p12|pfx|kdbx)([^a-z]|$)|id_(rsa|ed25519|ecdsa)
(private[_-]?key|BEGIN [A-Z ]*PRIVATE KEY)|/(secrets?|keystore|credentials)/
\.env([^a-z]|$)|_authToken|Authorization: *(Bearer|Basic)
(ghp|gho|ghs|ghu)_[A-Za-z0-9]{16,}|github_pat_[A-Za-z0-9_]{20,}
xox[baprs]-|AKIA[0-9A-Z]{12,}|sk-[A-Za-z0-9]{16,}'

# --- self-test: if the canary does not match, the pattern is broken, not the input.
CANARY='ghp_aaaaaaaaaaaaaaaaaaaa 192.0.2.7 /secrets/x id_ed25519'
if ! printf '%s\n' "$CANARY" | grep -qEi "$PATTERNS" 2>/dev/null; then
  echo "redaction-scan: SCANNER BROKEN — pattern failed its own canary; fix before pushing" >&2
  exit 2
fi

if [ "$#" -gt 0 ]; then
  out=$(grep -nEi "$PATTERNS" "$@" 2>&1) ; status=$?
else
  out=$(git diff --cached -U0 | grep -nEi "$PATTERNS" 2>&1) ; status=$?
fi

case "$status" in
  0) printf '%s\n' "$out"
     echo "redaction-scan: FINDINGS above — stop and inspect each one (a hit is not automatically a block)" >&2
     exit 1 ;;
  1) echo "redaction-scan: no pattern hits. NOT a waiver — bare host aliases and node labels in prose are"
     echo "                mechanically undetectable; AGENTS.md §4 still binds. You are the check for those."
     exit 0 ;;
  *) echo "redaction-scan: SCANNER ERROR (grep exit $status): $out" >&2
     exit 2 ;;
esac
