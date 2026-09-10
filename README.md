# Coder

A `Coder<Input, Output, Buffer, Failure>` retains a typed parsing function and a
borrowed serialization function. Input and buffer may differ: a byte grammar can
consume `ArraySlice<UInt8>` and append to `[UInt8]`. `Coding` combines `Parsing`
and `Serializing`, keeping their shared, exact failure type, including `Never`.

Run the bidirectional record example with Swift 6.4:

```sh
swift run CoderUserRecords
swift test
```

[User Records](Examples/User%20Records/README.md) uses Unicode names, ASCII ages,
commas and mandatory LF. Its executable and tests use the same model and grammar.
[Derived Grammars](Examples/Derived%20Grammars) is a separate opt-in package for
record isomorphism and enum prism derivation; the runtime does not depend on macros.

## Construction and composition

The direct representation is explicit about both directions:

```swift
let digit = Coder<Substring, Int, String, DigitFailure>(
    parse: { input throws(DigitFailure) in
        guard let first = input.first, first >= "0", first <= "9",
              let digit = first.wholeNumberValue else { throw .expectedDigit }
        input.removeFirst()
        return digit
    },
    serialize: { digit, buffer throws(DigitFailure) in
        guard (0...9).contains(digit) else { throw .expectedDigit }
        buffer.append(contentsOf: String(digit))
    }
)
```

Declare `enum DigitFailure: Error { case expectedDigit }` with that example.
For a composed domain value, `Coder(forward, from: borrowedProjection) { ... }`
requires both arrows. The User Records source shows complete construction and
validation. `Parser(User.init) { ... }` and ordinary one-way `.map` remain parsers;
they do not acquire an inferred inverse.

The builder produces a structural `Pair<A, B>` for two retained outputs and a
nested `Pair<Pair<A, B>, C>` for three. It borrows each actual field when writing.
There is no tuple-layout cast. `Void` nodes retain their canonical syntax and can
appear before or after retained values; arbitrary discarded values are not
printable without an explicit reconstruction rule.

Domain types can use an expressive body:

```swift
@Coder::Builder<Substring, String>
var body: some Coding<Substring, User, String, RecordFailure> {
    // A Coder constructor and its retained composition, as in User.Coder.
}
```

Swift 6.4 sees competing inherited result-builder attributes from `Parsing` and
`Serializing`. Use the explicit `@Coder::Builder` annotation for a multi-expression
body, or `return Coder(...) { ... }` for a single constructed body. Inferred
associated types and exact failures are preserved. Some fallible closure call
sites need an explicit `throws(Failure)` annotation. A nonthrowing writer and
nonthrowing bidirectional conversion have convenience overloads. Use
`Coder(Input.self, Buffer.self) { ... }` when unit nodes need explicit cursor and
buffer context. Pair/Skip composition collapses mixed `Never` and `E` failures to
exactly `E`; two infallible children remain `Never`.

## Recovery, validation, and boundaries

- `Repetition(bounds, operation: coder).coder(rejected:failure:)` repeats using
  `Cardinal.Range` bounds. Add `separatedBy:` for a `Void` separator. The classifier
  decides which failures end repetition; an arbitrary `Either` has no implicit
  recovery meaning. A rejected separator plus element attempt is restored as one
  unit. Fatal failures propagate with consumption preserved.
- Count bounds are checked before serialization writes. Serialization errors from
  any present element or separator propagate. Parsing detects a successful
  iteration that made no progress and throws the mapped `.noProgress` error.
- `coder.optional(rejected:)` is input-driven optionality. A rejected parse is
  restored and becomes `nil`; fatal errors propagate. Serializing `.some(value)`
  must succeed or throw. `Swift.Optional<Content>.Coder` instead models a grammar
  branch that was present or absent when the grammar was constructed.
- `coder.filter(Predicate { ... }, failure:)` validates borrowed values in both
  directions. Parsing validates after consumption; serialization validates before
  writing the value. `OneOf.Sequence(absent:)` retries only the designated failure
  and restores both rejected input attempts and rejected buffer writes, including
  the final rejected arm. Fatal failures are not retried.
- `parse` is a prefix operation. `parseAll(input, or: failure)` additionally requires
  an empty input collection. Reaching a repetition maximum leaves the next token
  unread; use `parseAll` when leftovers must be rejected.

A `Coding` conformance retains capabilities; it cannot mechanically prove all
round-trip laws. Adjacent greedy tokens need delimiters, lengths, escaping, or
another unambiguous boundary. Repeated elements must consume input, and an optional
grammar must reject its absent representation. A generic buffer cannot inspect a
future suffix or verify emitted progress. Restoration applies only to the supplied
`Restorable` cursor/buffer, not shared reference state or external side effects.

## Optics and ownership

`.map(to:from:)` retains a consuming forward conversion and a borrowed reverse
projection in `Map.Coder`. `.mapFailure` retains its upstream in
`Map.Error.Coder`. Both support noncopyable components without closure aliases.
`Optic.Isomorphism`, `.Isomorphism.Partial`, and `.Adapter` overloads retain both
arrows; fallible optics require explicit forward/backward failure mapping into the
shared grammar failure. An adapter may canonicalize. A partial isomorphism's laws
apply to its supported subset; canonical lexical spelling is a separate contract.

`Coder::Case(prism, absent:) { tag; payload }` retains explicit textual tags.
Copyable cases can use optional extraction, including generated `extract: \.leaf`.
A noncopyable source uses `Case(prism, fold, absent:)`: the prism embeds a parsed
focus and the fold lends a borrowed focus during serialization. Case content, source and focus may be noncopyable.

Choose a concrete representation such as `User.Coder()` and call its `parse` or
`serialize` method. Generic functions take a `Coding` value explicitly, so the
caller selects the format. There is no model-level `Codable` selector or implicit
`encode`, `encoded`, or decoding initializer.

Direct coder functions support noncopyable and scoped inputs/outputs. The closure
builder constructor requires copyable composition and escapable output; concrete
`Coding` bodies, `Pair.Coder`, `Skip.Coder`, conversion, predicate and input-driven
`OneOf.Optional` wrappers retain noncopyable components. Construction-time
`Swift.Optional<Content>.Coder` and builder `if` without `else` currently require
copyable content. Repetition also retains noncopyable
operation/separator components but its array collector needs copyable, escapable
values. A consuming optic backward arrow requires a copyable new domain value;
use a borrowed `from:` projection otherwise. These restrictions are compiler-tested,
including `Span` input/output and resource destruction. Direct `OneOf.Two` also
retains noncopyable branches; `OneOf.Sequence` and its deferred builder currently
require copyable branches because they store factory closures.

## Traits and migration

The default enables `Always`, `Either`, `Pair`, `Skip`, `Map`, `Optic`, `Checkpoint`,
`Repetition`, and `Predicate`. Select `traits: []` for the direct core, or request
individual traits in a package dependency. Directional Parser/Serializer traits
are forwarded only when selected. Their independent algebra packages remain
separate. For example:

```sh
swift test --disable-default-traits
swift test --disable-default-traits --traits Pair
swift test --disable-default-traits --traits Pair,Skip,Map
```

| Previous spelling | Replacement |
| --- | --- |
| `Coder.Protocol`, `Coder.Witness` | `Coding`, direct `Coder<Input, Output, Buffer, Failure>` |
| `Coder.Sequence { ... }` | `Coder { ... }` or a concrete `Coding.body` |
| `Coder.Builder` | `Coder::Builder<Input, Buffer>` when module qualification is needed |
| Tuple append/layout splitting | Structural `Pair` fields; explicit tuple bridge if needed |
| `Pair<...>.Parser` used as a coder | `Pair<...>.Coder` / `.coder()` |
| `Coder.Case`, `Coder.OneOf` | Module-scoped `Coder::Case`, `Coder::OneOf` |
| `Coder.Codable`, model `encode` / `encoded` / `init(decoding:)` | Pass an explicit `Coding` representation and call `serialize` / `parse` |
| Cursor `Parser.Many` / `Parser.Optionally` coder adapters | `Repetition.Coder` / `.optional(rejected:)` |
| `Always(()).parser()` used as a coder | `Always(()).coder(for:into:)` |

The Pair, Optic, Checkpoint, Cursor, and Always Coder integration packages are
compatibility imports of the core traits. Their old competing implementations
were removed. Parser/Serializer-only adaptations do not become coders implicitly.

`Tests/Compile Failures` contains negative compiler fixtures for one-way mapping
and arbitrary skipped values. Run its checker against the built module directory.
The HTTP/RFC tests are focused boundary fixtures; they do not claim that the full
HTTP router or RFC package graph builds.
