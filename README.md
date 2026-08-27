# Coder

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-molecules/swift-coder/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-molecules/swift-coder/actions/workflows/ci.yml)

Bidirectional coding primitives — `Coder.Protocol` unifies a parser and a serializer into one codec type, so decode and encode of a format live on a single conformer with unified `Input` / `Output` / `Buffer` / `Failure`. Writing the two directions as separate parser and serializer types forces two names, two failure types, and a round-trip contract nobody checks; a coder is the format-times-value unit that carries both directions and the contract in one place.

The two directions are deliberately asymmetric: decode reads from a cursor `Input` (which may be non-copyable or non-escapable, such as a borrowed span), while encode appends to a mutable `Buffer`. Codecs whose two directions genuinely differ in type and failure mode fit here; text round-trips that share one input type and compose declaratively belong to `Parser.Bidirectional` in swift-parser instead.

---

## Key Features

- **One conformer, both directions** — `Coder.Protocol` refines the parser and serializer protocols; conforming once yields `parse(_:)` and `serialize(_:into:)` with a single unified failure type.
- **Typed throws end-to-end** — `Failure` is a type parameter on every surface; no `any Error` appears in the API. Codecs with distinct decode/encode failures populate `Failure` with `Either<DecodeFailure, EncodeFailure>` from swift-either.
- **Closure-backed witnesses** — `Coder.Witness` builds an ad-hoc codec from a parse closure and a serialize closure; `Coder.Pure` is the `Failure == Never` shorthand for infallible codecs.
- **Canonical-coder attachment** — the `Codable` protocol lets a value type declare its canonical coder, giving the type itself `init(decoding:)` and `encoded()`.
- **Leaf by design** — coders do not compose through a `body` builder; combinators belong on parsers and serializers, and a coder is the terminal format-times-value unit.

Note: the package's `Codable` protocol intentionally shadows `Swift.Codable`. Code that needs Swift's built-in protocol alongside this package writes `Swift.Codable` explicitly.

---

## Quick Start

```swift
import Coder

struct TruncatedInput: Error {}

// One value for both directions: a big-endian UInt16 codec.
let uint16BE = Coder.Witness<ArraySlice<UInt8>, UInt16, [UInt8], TruncatedInput>(
    parse: { (input) throws(TruncatedInput) in
        guard let high = input.popFirst(), let low = input.popFirst() else {
            throw TruncatedInput()
        }
        return UInt16(high) << 8 | UInt16(low)
    },
    serialize: { value, buffer in
        buffer.append(UInt8(value >> 8))
        buffer.append(UInt8(truncatingIfNeeded: value))
    }
)

var wire: ArraySlice<UInt8> = [0x01, 0x02]
let port = try uint16BE.parse(&wire)        // 258, wire fully consumed
var encoded: [UInt8] = []
try uint16BE.serialize(port, into: &encoded) // [0x01, 0x02] — round-trips by construction
```

A type can adopt its codec as canonical via `Codable`, so decode and encode become members of the type itself:

```swift
struct Port { var number: UInt16 }

extension Port: Coder.Codable {
    static var coder: Coder.Coder.Witness<ArraySlice<UInt8>, Port, [UInt8], TruncatedInput> {
        .init(
            parse: { (input) throws(TruncatedInput) in
                guard let high = input.popFirst(), let low = input.popFirst() else {
                    throw TruncatedInput()
                }
                return Port(number: UInt16(high) << 8 | UInt16(low))
            },
            serialize: { port, buffer in
                buffer.append(UInt8(port.number >> 8))
                buffer.append(UInt8(truncatingIfNeeded: port.number))
            }
        )
    }
}

var input: ArraySlice<UInt8> = [0x01, 0x02]
let https = try Port(decoding: &input)      // Port(number: 258)
let bytes = try https.encoded()             // [0x01, 0x02]
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-coder.git", branch: "main")
]
```

Add the product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Coder", package: "swift-coder")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Coder` | `Coder.Protocol`, `Coder.Witness`, `Coder.Pure`, and the `Codable` attachment protocol | Most consumers |
| `Coder Test Support` | Re-export of `Coder` for test targets | Test targets that exercise codecs |

The surface is small and early: the protocol, one closure-backed witness, and the canonical-coder attachment. Combinator vocabulary lives in the parser and serializer packages this one refines; no coder-side combinators exist yet.

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |

---

## Related Packages

- [`swift-parser`](https://github.com/swift-molecules/swift-parser) — the parser vocabulary `Coder.Protocol` refines; use `Parser.Bidirectional` there when both directions share one input type and compose declaratively.
- [`swift-serializer`](https://github.com/swift-molecules/swift-serializer) — the serializer vocabulary `Coder.Protocol` refines.
- [`swift-either`](https://github.com/swift-molecules/swift-either) — `Either<DecodeFailure, EncodeFailure>` for codecs with asymmetric failure modes.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
