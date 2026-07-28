#!/bin/sh
# Asserts redaction-scan.sh flags what it must and stays quiet on what it must not.
# The fixture is the only thing that would have caught BOTH published failures of this
# check (a `\b` inside a group; then in-string backslashes making it exit 2 silently).
set -u
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
scan="$here/redaction-scan.sh"
fixture="$here/redaction-fixture.txt"
tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
fails=0; checked=0

while IFS= read -r raw; do
  case "$raw" in ''|'#'*) continue ;; esac
  expect=${raw%%|*}; line=${raw#*|}
  printf '%s\n' "$line" > "$tmp"
  sh "$scan" "$tmp" >/dev/null 2>&1; rc=$?
  checked=$((checked+1))
  if [ "$rc" -ge 2 ]; then
    echo "SCANNER BROKEN while checking: $line" >&2; fails=$((fails+1)); continue
  fi
  got=MISS; [ "$rc" -eq 1 ] && got=HIT
  if [ "$got" != "$expect" ]; then
    echo "FAIL expected $expect got $got: $line" >&2; fails=$((fails+1))
  fi
done < "$fixture"

[ "$checked" -gt 0 ] || { echo "FAIL: fixture empty — the harness proves nothing" >&2; exit 1; }
if [ "$fails" -gt 0 ]; then echo "$fails/$checked fixture expectations failed" >&2; exit 1; fi
echo "redaction-scan: $checked/$checked fixture expectations met"
