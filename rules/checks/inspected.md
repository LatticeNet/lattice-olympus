# Inspected findings ledger

`redaction-scan.sh` fails on findings. When a finding is legitimate — this repo writes ABOUT
the patterns, so it happens — record it here with a reason and it stops failing CI. Format:

    <exact snippet from the flagged line>|<why it is safe>

Rules for this file, which are the whole point of it existing:

- **Recorded is not safe.** An entry is a claim a human made, reviewed in the diff like any
  other change. If an entry looks like a mute button, challenge it in review.
- Snippets must be **specific**. `kdbx` is a category word; a path or a token value is not —
  those should be redacted, never recorded.
- If you find yourself adding an entry to make a red job green **before** understanding the
  hit, stop: that is the laundering step this whole check exists to prevent.

`.kdbx`|discussion of the scanner's own pattern branches in a review letter (no path, no file)
`.pem`|same — category names quoted while reviewing the pattern set
