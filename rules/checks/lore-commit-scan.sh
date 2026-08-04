#!/bin/sh
# Verify that every intended Lore field is a native Git trailer.
#
# Usage: rules/checks/lore-commit-scan.sh                 # origin/main..HEAD
#        rules/checks/lore-commit-scan.sh REV [REV ...]   # commits or ranges
#
# Exit: 0 = clean · 1 = malformed commit(s) · 2 = scanner/input broken.
set -u

KEYS='Constraint
Rejected
Confidence
Scope-risk
Reversibility
Directive
Tested
Not-tested
Related
Corrects-Lore-Commit'
KEY_PATTERN='(Constraint|Rejected|Confidence|Scope-risk|Reversibility|Directive|Tested|Not-tested|Related|Corrects-Lore-Commit)'

tmpdir=$(mktemp -d) || exit 2
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
commits="$tmpdir/commits"
unique="$tmpdir/unique"
if ! : > "$commits"; then
  echo "lore-commit-scan: SCANNER ERROR — cannot initialize the commit list" >&2
  exit 2
fi

count_nonempty() {
  count=$(grep -c . "$1" 2>"$tmpdir/count-error"); rc=$?
  if [ "$rc" -ge 2 ]; then
    echo "lore-commit-scan: SCANNER ERROR — cannot count $1" >&2
    cat "$tmpdir/count-error" >&2
    return 2
  fi
  printf '%s\n' "$count"
}

canary="$tmpdir/canary"
printf 'Subject\n\nConstraint: canary\nTested: canary\n' > "$canary" || {
  echo "lore-commit-scan: SCANNER BROKEN — cannot write the canary" >&2
  exit 2
}
grep -E "^$KEY_PATTERN:" "$canary" > "$tmpdir/canary-physical" 2>"$tmpdir/canary-grep-error"; rc=$?
if [ "$rc" -ge 2 ]; then
  echo "lore-commit-scan: SCANNER BROKEN — physical canary grep failed" >&2
  cat "$tmpdir/canary-grep-error" >&2
  exit 2
fi
git interpret-trailers --parse < "$canary" > "$tmpdir/canary-parsed" 2>"$tmpdir/canary-parse-error" || {
  echo "lore-commit-scan: SCANNER BROKEN — native parser failed its canary" >&2
  cat "$tmpdir/canary-parse-error" >&2
  exit 2
}
grep -E "^$KEY_PATTERN:" "$tmpdir/canary-parsed" > "$tmpdir/canary-parsed-keys" 2>"$tmpdir/canary-grep-error"; rc=$?
if [ "$rc" -ge 2 ]; then
  echo "lore-commit-scan: SCANNER BROKEN — parsed canary grep failed" >&2
  cat "$tmpdir/canary-grep-error" >&2
  exit 2
fi
canary_physical=$(count_nonempty "$tmpdir/canary-physical") || exit 2
canary_parsed=$(count_nonempty "$tmpdir/canary-parsed-keys") || exit 2
if [ "$canary_physical" -ne 2 ] || [ "$canary_parsed" -ne 2 ]; then
  echo "lore-commit-scan: SCANNER BROKEN — native-trailer canary expected 2/2, got $canary_physical/$canary_parsed" >&2
  exit 2
fi

if [ "$#" -eq 0 ]; then
  set -- 'refs/remotes/origin/main..HEAD'
fi

for spec in "$@"; do
  case "$spec" in
    *..*)
      if ! git rev-list --reverse "$spec" >> "$commits" 2>"$tmpdir/rev-error"; then
        echo "lore-commit-scan: INPUT ERROR — cannot resolve range $spec" >&2
        cat "$tmpdir/rev-error" >&2
        exit 2
      fi
      ;;
    *)
      commit=$(git rev-parse --verify "$spec^{commit}" 2>"$tmpdir/rev-error") || {
        echo "lore-commit-scan: INPUT ERROR — cannot resolve commit $spec" >&2
        cat "$tmpdir/rev-error" >&2
        exit 2
      }
      printf '%s\n' "$commit" >> "$commits" || {
        echo "lore-commit-scan: SCANNER ERROR — cannot record resolved commit $commit" >&2
        exit 2
      }
      ;;
  esac
done

if ! awk '!seen[$0]++' "$commits" > "$unique"; then
  echo "lore-commit-scan: SCANNER ERROR — cannot de-duplicate the resolved commit list" >&2
  exit 2
fi
commits_scanned=$(count_nonempty "$unique") || exit 2
violations=0
physical_total=0
escaped_total=0
parsed_total=0

while IFS= read -r commit; do
  [ -n "$commit" ] || continue
  msg="$tmpdir/msg-$commit"
  parsed="$tmpdir/parsed-$commit"
  physical_names="$tmpdir/physical-$commit"
  parsed_names="$tmpdir/parsed-names-$commit"
  escaped_names="$tmpdir/escaped-$commit"
  physical_raw="$tmpdir/physical-raw-$commit"
  parsed_raw="$tmpdir/parsed-raw-$commit"
  escaped_raw="$tmpdir/escaped-raw-$commit"

  git show -s --format=%B "$commit" > "$msg" 2>"$tmpdir/show-error" || {
    echo "lore-commit-scan: SCANNER ERROR — cannot read $commit" >&2
    cat "$tmpdir/show-error" >&2
    exit 2
  }
  git interpret-trailers --parse < "$msg" > "$parsed" 2>"$tmpdir/parse-error" || {
    echo "lore-commit-scan: SCANNER ERROR — native parser failed for $commit" >&2
    cat "$tmpdir/parse-error" >&2
    exit 2
  }

  if ! sed -nE "s/^$KEY_PATTERN:.*/\\1/p" "$msg" > "$physical_raw"; then
    echo "lore-commit-scan: SCANNER ERROR — cannot extract physical keys from $commit" >&2
    exit 2
  fi
  if ! sort "$physical_raw" > "$physical_names"; then
    echo "lore-commit-scan: SCANNER ERROR — cannot sort physical keys for $commit" >&2
    exit 2
  fi
  if ! sed -nE "s/^$KEY_PATTERN:.*/\\1/p" "$parsed" > "$parsed_raw"; then
    echo "lore-commit-scan: SCANNER ERROR — cannot extract parsed keys from $commit" >&2
    exit 2
  fi
  if ! sort "$parsed_raw" > "$parsed_names"; then
    echo "lore-commit-scan: SCANNER ERROR — cannot sort parsed keys for $commit" >&2
    exit 2
  fi
  if ! : > "$escaped_raw"; then
    echo "lore-commit-scan: SCANNER ERROR — cannot initialize escaped keys for $commit" >&2
    exit 2
  fi
  printf '%s\n' "$KEYS" > "$tmpdir/keys" || {
    echo "lore-commit-scan: SCANNER ERROR — cannot prepare the key list" >&2
    exit 2
  }
  while IFS= read -r key; do
    [ -n "$key" ] || continue
    matches="$tmpdir/escaped-matches-$commit-$key"
    grep -Eo "\\\\n(\\\\n)*$key:" "$msg" > "$matches" 2>"$tmpdir/escaped-grep-error"; rc=$?
    if [ "$rc" -ge 2 ]; then
      echo "lore-commit-scan: SCANNER ERROR — escaped-key grep failed for $commit" >&2
      cat "$tmpdir/escaped-grep-error" >&2
      exit 2
    fi
    count=$(count_nonempty "$matches") || exit 2
    i=0
    while [ "$i" -lt "$count" ]; do
      printf '%s\n' "$key" >> "$escaped_raw" || {
        echo "lore-commit-scan: SCANNER ERROR — cannot record escaped keys for $commit" >&2
        exit 2
      }
      i=$((i + 1))
    done
  done < "$tmpdir/keys"
  if ! sort "$escaped_raw" > "$escaped_names"; then
    echo "lore-commit-scan: SCANNER ERROR — cannot sort escaped keys for $commit" >&2
    exit 2
  fi

  physical=$(count_nonempty "$physical_names") || exit 2
  escaped=$(count_nonempty "$escaped_names") || exit 2
  parsed_count=$(count_nonempty "$parsed_names") || exit 2
  physical_total=$((physical_total + physical))
  escaped_total=$((escaped_total + escaped))
  parsed_total=$((parsed_total + parsed_count))

  cmp -s "$physical_names" "$parsed_names"; cmp_rc=$?
  if [ "$cmp_rc" -ge 2 ]; then
    echo "lore-commit-scan: SCANNER ERROR — cannot compare physical and parsed keys for $commit" >&2
    exit 2
  fi
  if [ "$escaped" -gt 0 ] || [ "$cmp_rc" -ne 0 ]; then
    violations=$((violations + 1))
    echo "lore-commit-scan: MALFORMED $commit physical=$physical escaped=$escaped parsed=$parsed_count" >&2
  fi
done < "$unique"

echo "lore-commit-scan: commits_scanned=$commits_scanned violations=$violations physical=$physical_total escaped=$escaped_total parsed=$parsed_total"
if [ "$violations" -gt 0 ]; then
  echo "lore-commit-scan: FINDINGS — originals remain malformed; no SHA allowlist or automatic waiver exists" >&2
  exit 1
fi
exit 0
