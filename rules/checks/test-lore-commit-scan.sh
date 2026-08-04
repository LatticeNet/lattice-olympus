#!/bin/sh
# Falsifiable tests for lore-commit-scan.sh.
set -u

here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=$(git -C "$here" rev-parse --show-toplevel) || exit 1
scan="$here/lore-commit-scan.sh"
repo=$(mktemp -d) || exit 1
trap 'rm -rf "$repo"' EXIT HUP INT TERM

git -C "$repo" init -q
git -C "$repo" config user.name test
git -C "$repo" config user.email test

state="$repo/state"
msg="$repo/message"
out="$repo/output"
checked=0
failed=0

commit_nonempty() {
  printf '%s\n' "$1" >> "$state"
  git -C "$repo" add state
  git -C "$repo" commit -q -F "$msg"
  git -C "$repo" rev-parse HEAD
}

check_case() { # repo expected-exit label revision expected-summary-fragment
  target_repo=$1; expected=$2; label=$3; revision=$4; fragment=$5
  (cd "$target_repo" && sh "$scan" "$revision") > "$out" 2>&1; rc=$?
  checked=$((checked + 1))
  if [ "$rc" -ne "$expected" ]; then
    echo "FAIL $label: expected exit $expected got $rc" >&2
    cat "$out" >&2
    failed=$((failed + 1))
  elif ! grep -qF "$fragment" "$out"; then
    echo "FAIL $label: missing summary fragment: $fragment" >&2
    cat "$out" >&2
    failed=$((failed + 1))
  else
    echo "PASS $label"
  fi
}

printf 'valid trailers\n\nContext.\n\nConstraint: one\nRejected: two | reason\nConfidence: high\nScope-risk: narrow\nDirective: five\nTested: six\nNot-tested: seven\nRelated: eight\n' > "$msg"
valid=$(commit_nonempty valid)
check_case "$repo" 0 'contiguous eight-trailer block' "$valid" 'commits_scanned=1 violations=0 physical=8 escaped=0 parsed=8'

printf 'blank-separated fields\n\nConstraint: one\n\nRejected: two | reason\n\nConfidence: high\n\nScope-risk: narrow\n\nDirective: five\n\nTested: six\n\nNot-tested: seven\n\nRelated: eight\n' > "$msg"
blank=$(commit_nonempty blank)
check_case "$repo" 1 'blank-separated eight fields' "$blank" 'commits_scanned=1 violations=1 physical=8 escaped=0 parsed=1'

printf '%s\n' 'literal escapes\n\nConstraint: one\nRejected: two | reason\nConfidence: high\nScope-risk: narrow\nDirective: five\nTested: six\nNot-tested: seven\nRelated: eight' > "$msg"
literal=$(commit_nonempty literal)
check_case "$repo" 1 'literal backslash-n message' "$literal" 'commits_scanned=1 violations=1 physical=0 escaped=8 parsed=0'

printf 'valid tail after malformed head\n\nTested: range scan\n' > "$msg"
range_tail=$(commit_nonempty range-tail)
check_case "$repo" 1 'two-commit range catches non-tip defect' "$blank..$range_tail" 'commits_scanned=2 violations=1'

printf 'plain commit with no optional Lore fields\n' > "$msg"
plain=$(commit_nonempty plain)
check_case "$repo" 0 'plain message (trailers optional)' "$plain" 'commits_scanned=1 violations=0 physical=0 escaped=0 parsed=0'

check_case "$repo" 2 'unresolvable input' 'does-not-exist' 'INPUT ERROR'

badbin="$repo/badbin"
mkdir "$badbin"
printf '#!/bin/sh\nexit 9\n' > "$badbin/awk"
chmod +x "$badbin/awk"
(cd "$repo" && PATH="$badbin:$PATH" sh "$scan" "$valid") > "$out" 2>&1; rc=$?
checked=$((checked + 1))
if [ "$rc" -ne 2 ] || ! grep -qF 'SCANNER ERROR' "$out"; then
  echo "FAIL helper fault injection: expected loud exit 2, got $rc" >&2
  cat "$out" >&2
  failed=$((failed + 1))
else
  echo 'PASS helper fault injection fails closed'
fi

check_case "$root" 0 'real valid control 4496c52' '4496c52f55758368d5b43fa5842bcbf7dc625981' 'commits_scanned=1 violations=0 physical=9 escaped=0 parsed=9'
check_case "$root" 1 'real pushed malformed 17b847b' '17b847b' 'commits_scanned=1 violations=1 physical=0 escaped=7 parsed=0'
check_case "$root" 1 'real outbound malformed 45eefd4' '45eefd4' 'commits_scanned=1 violations=1 physical=0 escaped=8 parsed=0'

if [ "$checked" -ne 10 ]; then
  echo "FAIL expected 10 cases, ran $checked" >&2
  exit 1
fi
if [ "$failed" -gt 0 ]; then
  echo "lore-commit-scan: $failed/$checked cases failed" >&2
  exit 1
fi
echo "lore-commit-scan: $checked/$checked cases passed"
