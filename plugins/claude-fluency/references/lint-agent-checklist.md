# Emoji lint checklist

- Source tree scanned for emoji Unicode ranges, excluding `.git/`, `node_modules/`, `vendor/`, lockfiles, and binaries.
- Emoji inside SQL strings (raw queries, ORM `.raw()` calls, migrations) are flagged for encoding/truncation risk, not treated as cosmetic.
- Emoji inside cloud-service queries, filter expressions, tags, or resource identifiers are flagged for silent-strip/double-encode risk.
- Emoji inside code identifiers (variables, functions, classes, file names) are flagged as a portability/tooling issue.
- Emoji in comments or human-facing strings (logs, CLI output, UI copy) are noted but not escalated.
- Emoji inside test fixtures whose purpose is testing Unicode/emoji handling are excluded — intentional coverage, not a finding.
