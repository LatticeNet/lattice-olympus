#!/bin/sh
# Asserts redaction-scan.sh flags what it must and stays quiet on what it must not.
# The fixture is the only thing that would have caught BOTH published failures of this
# check (a `\b` inside a group; then in-string backslashes making it exit 2 silently).
set -u
# Hermetic: the fixture cases must behave identically whether or not the caller happens
# to export REDACTION_INSPECTED. They did not — an exported ledger in my shell waived a
# fixture line and the harness reported a failure that CI could not reproduce. A test
# whose result depends on ambient environment is testing the environment.
unset REDACTION_INSPECTED
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
scan="$here/redaction-scan.sh"
fixture="$here/redaction-fixture.txt"
tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
fails=0; checked=0

while IFS= read -r raw; do
  case "$raw" in ''|'#'*) continue ;; esac
  expect=${raw%%|*}; line=${raw#*|}
  printf '%s\n' "$line" > "$tmp"
  REDACTION_INSPECTED= sh "$scan" "$tmp" >/dev/null 2>&1; rc=$?
  checked=$((checked+1))
  if [ "$rc" -ge 2 ]; then
    echo "SCANNER BROKEN while checking: $line" >&2; fails=$((fails+1)); continue
  fi
  got=MISS; [ "$rc" -eq 1 ] && got=HIT
  if [ "$got" != "$expect" ]; then
    echo "FAIL expected $expect got $got: $line" >&2; fails=$((fails+1))
  fi
done < "$fixture"

# --- ledger behaviour. The ledger is a waiver path, so it needs the harder tests:
# it must NOT blanket-pass, and a ledger it cannot apply must fail loudly rather than
# quietly emptying the findings (which is what the first version did).
led=$(mktemp); a=$(mktemp); b=$(mktemp); c=$(mktemp); trap 'rm -f "$tmp" "$led" "$a" "$b" "$c"' EXIT
printf 'ZZZ-recorded-marker|test entry\n' > "$led"
printf 'a line with ZZZ-recorded-marker in it\n' > "$a"
printf 'token ghp_aaaaaaaaaaaaaaaaaaaaaaaa\n' > "$b"
cat "$a" "$b" > "$c"
ledger_case() { # <file> <expected-exit> <label>
  REDACTION_INSPECTED="$led" sh "$scan" "$1" >/dev/null 2>&1; rc=$?
  checked=$((checked+1))
  if [ "$rc" -ne "$2" ]; then echo "FAIL ledger/$3: expected exit $2 got $rc" >&2; fails=$((fails+1));
  else echo "PASS (ledger)     $3"; fi
}
ledger_case "$a" 0 "recorded finding is waived"
ledger_case "$b" 1 "UNRECORDED finding still fails"
ledger_case "$c" 1 "one unrecorded finding outweighs a recorded one"

# A ledger entry short enough to match most diff lines is a mute button. It must break
# the scanner loudly, not waive the scan and print success.
# The `.pem` ledger entry must waive the CATEGORY quoted in prose and never a real path.
# That specificity lives in the entry's backticks and is invisible — this asserts it.
real=$(mktemp)
printf 'backup key at /srv/keys/production.pem\n' > "$real"
REDACTION_INSPECTED="$here/inspected.md" sh "$scan" "$real" >/dev/null 2>&1; rc=$?
checked=$((checked+1))
if [ "$rc" -ne 1 ]; then echo "FAIL ledger/real-path: expected exit 1 got $rc — an entry widened into a real path" >&2; fails=$((fails+1));
else echo "PASS (ledger)     real credential path NOT waived by the category entry"; fi
rm -f "$real"

short=$(mktemp)
for tiny in '+' ' ' 'ab'; do
  printf '%s|too short\n' "$tiny" > "$short"
  REDACTION_INSPECTED="$short" sh "$scan" "$b" >/dev/null 2>&1; rc=$?
  checked=$((checked+1))
  if [ "$rc" -ne 2 ]; then echo "FAIL ledger/short '$tiny': expected exit 2 got $rc" >&2; fails=$((fails+1));
  else echo "PASS (ledger)     entry '$tiny' rejected as too short"; fi
done
rm -f "$short"

[ "$checked" -gt 0 ] || { echo "FAIL: fixture empty — the harness proves nothing" >&2; exit 1; }
if [ "$fails" -gt 0 ]; then echo "$fails/$checked fixture expectations failed" >&2; exit 1; fi
echo "redaction-scan: $checked/$checked fixture expectations met"
