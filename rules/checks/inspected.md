# Inspected findings ledger

`redaction-scan.sh` fails on findings. When a finding is legitimate — this repo writes ABOUT
the patterns, so it happens — record it here with a reason and it stops failing CI. Format:

    <exact snippet from the flagged line>|<why it is safe>

Rules for this file, which are the whole point of it existing:

- **Recorded is not safe.** An entry is a claim a human made, reviewed in the diff like any
  other change. If an entry looks like a mute button, challenge it in review.
- Snippets must be **specific**. `kdbx` is a category word; a path or a token value is not —
  those should be redacted, never recorded.
- **Delimiters are part of the entry, not formatting.** The entries below are `` `.pem` ``
  *with backticks* — they waive the category name quoted as code in prose, and NOT a real path
  like a realistic credential path (verified: that line is still flagged). "Tidying" the
  backticks away would silently widen an entry into a genuine hole. Do not clean this file.
- **Entries under 4 characters are refused** by the scanner (exit 2): a one-character entry
  matches nearly every line of a diff, which is a mute button that also announces success.
- If you find yourself adding an entry to make a red job green **before** understanding the
  hit, stop: that is the laundering step this whole check exists to prevent.

`.kdbx`|discussion of the scanner's own pattern branches in a review letter (no path, no file)
`.pem`|same — category names quoted while reviewing the pattern set
ghp_aaaaaaaaaaaaaaaaaaaaaaaa|synthetic token literal inside test-redaction-scan.sh — the harness needs a matching input to prove the UNRECORDED-finding case still fails; all-`a` value, matches no real credential shape beyond the prefix
