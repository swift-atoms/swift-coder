# Bidirectional User Records

Run `swift run CoderUserRecords` from `swift-coder`. The executable and tests import
the same `User Records Model` target. This is a sibling of the unchanged
`swift-parser/Examples/User Records` example; its model and lexical rules are
explicitly traced to that source (2026-09-09).

A record is one or more Unicode letters/spaces, a comma, one or more ASCII decimal
digits, and LF. Ages must fit `Int` and be in `0...130`. Leading zeroes are accepted
and serialize canonically. There is no quoting, escaping, CRLF or CSV dialect.

`User.Coder.body` builds the complete lexical record into a safe `Pair<String,
String>` and only then validates/constructs `User`. Its explicit borrowed reverse
projection validates the name and age before any record bytes are written.
`UserRecords` repeats it through core `Repetition.Coder`, accepting an empty batch.

- `Élodie van Dijk,0042\n` parses and prints `Élodie van Dijk,42\n`.
- Prefix parsing preserves the next record or suffix. `whole` delegates to
  `parseAll`, rejecting leftovers.
- A syntactically rejected record is restored in its entirety by repetition,
  including its already consumed name and comma.
- Invalid age validation is fatal after the complete record and LF have matched.
  Earlier records and the invalid record remain consumed; later records remain.
- Missing comma/LF and non-ASCII digits reject. Invalid serialized names/ages
  throw before changing the output buffer.

The guarantee is a domain-value round trip and canonical wire spelling, not exact
preservation of leading zeroes. Textual framing is part of the grammar. Neither
repetition restoration nor validation reverses external side effects.
