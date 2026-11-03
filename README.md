# swift-coder

Use this package when one grammar must both parse a value from input and print it back into a buffer, so the two directions cannot drift apart. Start from `Coding`: conform with a `body` written in a `Builder` block, or as a leaf that implements `parse` and `serialize` directly, or build one from two closures with `Coder`. If you only ever read, use `Parsing` from swift-parser; if you only ever write, use `Serializing` from swift-serializer.

## Laws

- A `Builder` block runs its components in written order, in both directions. A component whose output is `Void` reads and writes its spelling but adds nothing to the output; two value components pair, nesting to the left.
- A leaf coder (one with no `body`) must implement both `parse` and `serialize`. Reading its `body` traps.
- Failures do not roll back by default. A coder that fails leaves consumed input consumed and written output written. Only `OneOf.Sequence`, `OneOf.Two`, `OneOf.Optional` and `Repetition<Bounds, Operation>.Coder<Separator>` restore, and only for a failure they classify as a rejection.
- Rejection versus fatal failure: `OneOf.Sequence` and `OneOf.Two` treat a failure equal to their `absent` value as a rejection; `OneOf.Optional` and `Repetition<Bounds, Operation>.Coder<Separator>` ask their `rejected` closure. A rejection restores the input or buffer to the checkpoint taken before the attempt. Any other failure propagates at once, without restoring and without trying later alternatives.
- `OneOf.Sequence` tries alternatives in written order, for parsing and for printing, and the first that does not reject wins. Printing therefore uses the first alternative that accepts the value. When every alternative rejects, it restores to before the whole choice and throws `absent`, even if the alternatives had written something.
- `Case` printing throws its `absent` value, writing nothing, when the value is not its case.
- `OneOf.Optional` parses a rejection as `nil` and consumes nothing. Printing `nil` writes nothing. Printing a present value that fails throws that failure; it is never turned into absence.
- `Repetition<Bounds, Operation>.Coder<Separator>` parsing is greedy. It stops at the bound's maximum without reading further, so the rest of the input is left for the next coder rather than rejected. It stops at the first rejected element and restores both that element and the separator before it. Elements already accepted stay consumed. If it stopped with fewer than the minimum, it fails. An element that succeeds without consuming input fails the repetition instead of looping, and the input is restored. Separators are read and written only between elements.
- `Repetition<Bounds, Operation>.Coder<Separator>` and the `Parser::Many` serializers check the element count against the bounds before writing anything. Empty bounds fail both directions before any work.
- With the Choice trait, `Parser::OneOf.Two` prints each alternative into a fresh staging buffer. It appends what was staged only if that alternative succeeds or fails without rejecting. When both reject, nothing is written.
- `Predicate<T>.Coder<Upstream>` checks in both directions. A parse consumes the value before the check, so a failed check leaves that input consumed. Printing checks before writing.
- Mapping (`map`, `Map<Source, Target, Failure>.Coder<Upstream>`) applies `forward` after parsing and `backward` before printing. A round trip holds only where the conversion's own laws hold, and only up to normalisation: printing a parsed value gives the canonical spelling, not the original one (`007` prints as `7`).
- `parseAll` succeeds only if the coder consumes the whole input. Otherwise it throws the failure it was given.
- An `if` in a `Builder` block fixes its branch when the coder is built; the branches are not tried as alternatives. Without an `else`, the absent branch parses `nil` and consumes nothing. Printing fails, writing nothing, when the value's presence does not match the branch's. `Either.Coder` tags each branch's failure with the side it came from.
- `Always<Void>.Coder` consumes nothing and writes nothing. `Swift.Never.Coder` always fails to parse and consumes nothing.
- `Swift.String.Coder` consumes every remaining byte and rejects input that is not valid UTF-8. `Swift.String.Coder.Lossless` parses through that text and the value's string initialiser, and prints the value's `description`.
- `First.Where` checks its predicate before appending when printing.
