#if Either && Pair && Skip && Map
    import Coder
    import Parser
    import Serializer
    import Testing

    @Suite
    struct `Coders preserve round trips composition and typed failure behavior` {

        @Test
        func `a leaf coder round-trips`() throws(any Swift.Error) {
            try roundTrip(Constant("abc"), "abc", expecting: "abc")
        }

        @Test
        func `a coder body backed by a witness round-trips`() throws(any Swift.Error) {
            try roundTrip(WitnessLeaf(), "x", expecting: "x")
        }

        @Test
        func `Skip.First round-trips`() throws(any Swift.Error) {
            try roundTrip(LeadingMarker(), "tag", expecting: "<tag")
        }

        @Test
        func `Skip.Second round-trips`() throws(any Swift.Error) {
            try roundTrip(TrailingMarker(), "tag", expecting: "tag>")
        }

        @Test
        func `Append round-trips a flat tuple`() throws(any Swift.Error) {
            var buffer: Substring = ""
            try KeyValue().serialize(Pair("k", "v"), into: &buffer)
            #expect(buffer == "k=v")
            var cursor = buffer
            let parsed = try KeyValue().parse(&cursor)
            #expect(parsed.first == "k")
            #expect(parsed.second == "v")
            #expect(cursor.isEmpty)
        }

        @Test
        func `Pair composition safely retains differently sized elements`() throws(any Swift.Error) {
            let inner = Coder::Builder<Substring, Substring>.buildPartialBlock(
                accumulated: Wide(), next: Narrow())
            let node = Coder::Builder<Substring, Substring>.buildPartialBlock(
                accumulated: inner, next: Wide())
            var buffer: Substring = ""
            try node.serialize(Pair(Pair(1, 2), 3), into: &buffer)
            #expect(buffer == "123")
            var cursor = buffer
            let parsed = try node.parse(&cursor)
            #expect(parsed.first.first == 1)
            #expect(parsed.first.second == 2)
            #expect(parsed.second == 3)
            #expect(cursor.isEmpty)
        }

        @Test
        func `Sequence round-trips`() throws(any Swift.Error) {
            try roundTrip(Bracketed(), "tag", expecting: "<tag>")
        }

        @Test
        func `Coder Sequence round-trips a nested body`() throws(any Swift.Error) {
            try roundTrip(NativelySequenced(), "tag", expecting: "<tag>")
        }

        @Test
        func `Error.Map round-trips and maps both directions`() throws(any Swift.Error) {
            try roundTrip(Renamed(), "tag", expecting: "tag")
            var buffer: Substring = ""
            #expect(throws: Domain.malformed) {
                try Renamed().serialize("other", into: &buffer)
            }
            var cursor: Substring = "other"
            #expect(throws: Domain.malformed) {
                try Renamed().parse(&cursor)
            }
        }

        @Test
        func `Map round-trips through an isomorphism`() throws(any Swift.Error) {
            var buffer: Substring = ""
            try Boxed.Coder().serialize(Boxed(value: "1"), into: &buffer)
            #expect(buffer == "(1)")
            var cursor = buffer
            #expect(try Boxed.Coder().parse(&cursor) == Boxed(value: "1"))
            #expect(cursor.isEmpty)
        }

        @Test
        func `equally typed failures collapse through the whole body`() {
            requireFailure(Bracketed(), Mismatch.self)
            requireFailure(KeyValue(), Mismatch.self)
            requireFailure(Boxed.Coder(), Mismatch.self)
        }

        @Test
        func `a coder body infers Input Output and Buffer from its body`() throws(any Swift.Error) {
            let _: Bracketed.Input.Type = Substring.self
            let _: Bracketed.Output.Type = String.self
            let _: Bracketed.Buffer.Type = Substring.self
        }

        @Test
        func `a serialize mismatch throws and appends nothing`() {
            var buffer: Substring = "prefix:"
            #expect(throws: Mismatch.mismatch) {
                try Constant("a").serialize("b", into: &buffer)
            }
            #expect(buffer == "prefix:")
        }

        @Test
        func `a model uses its explicit representation to serialize and parse`() throws(any Swift.Error) {
            let coder = Boxed.Coder()
            var buffer: Substring = ""
            try coder.serialize(Boxed(value: "3"), into: &buffer)
            #expect(buffer == "(3)")
            var cursor = buffer
            #expect(try coder.parse(&cursor) == Boxed(value: "3"))
            #expect(cursor.isEmpty)
        }
    }

    private func roundTrip<C: Coding>(
        _ coder: C,
        _ value: String,
        expecting text: Substring
    ) throws(any Swift.Error) where C.Input == Substring, C.Output == String, C.Buffer == Substring {
        var buffer: Substring = ""
        try coder.serialize(value, into: &buffer)
        #expect(buffer == text)
        var cursor = buffer
        let parsed = try coder.parse(&cursor)
        #expect(parsed == value)
        #expect(cursor.isEmpty)
    }

    private func roundTrip<C: Coding>(
        _ coder: C,
        _ value: Character,
        expecting text: Substring
    ) throws(any Swift.Error) where C.Input == Substring, C.Output == Character, C.Buffer == Substring {
        var buffer: Substring = ""
        try coder.serialize(value, into: &buffer)
        #expect(buffer == text)
        var cursor = buffer
        let parsed = try coder.parse(&cursor)
        #expect(parsed == value)
        #expect(cursor.isEmpty)
    }

    private func requireFailure<C: Coding, Failure: Swift.Error>(
        _: borrowing C,
        _: Failure.Type
    )
    where
        C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable & ~Escapable, C.Buffer: ~Copyable & ~Escapable,
        C.Failure == Failure
    {}

    private enum Mismatch: Swift.Error, Equatable {
        case mismatch
    }

    private enum Domain: Swift.Error, Equatable {
        case malformed
    }

    private struct Constant: Coding {
        let text: String

        init(_ text: String) {
            self.text = text
        }

        func parse(_ input: inout Substring) throws(Mismatch) -> String {
            guard input.hasPrefix(text) else { throw .mismatch }
            input = input.dropFirst(text.count)
            return text
        }

        func serialize(_ output: String, into buffer: inout Substring) throws(Mismatch) {
            guard output == text else { throw .mismatch }
            buffer.append(contentsOf: text)
        }
    }

    private struct Marker: Coding {
        let text: String

        init(_ text: String) {
            self.text = text
        }

        func parse(_ input: inout Substring) throws(Mismatch) {
            guard input.hasPrefix(text) else { throw .mismatch }
            input = input.dropFirst(text.count)
        }

        func serialize(_ output: Void, into buffer: inout Substring) throws(Mismatch) {
            buffer.append(contentsOf: text)
        }
    }

    private struct WitnessLeaf: Coding {
        typealias Failure = Mismatch

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, Character, Substring, Mismatch> {
            Coder::Coder<Substring, Character, Substring, Mismatch>(
                parse: { input throws(Mismatch) in
                    guard let first = input.first else { throw .mismatch }
                    input = input.dropFirst()
                    return first
                },
                serialize: { output, buffer in buffer.append(output) }
            )
        }
    }

    private struct Digit: Coding {
        func parse(_ input: inout Substring) throws(Mismatch) -> Character {
            guard let first = input.first, first.isNumber else { throw .mismatch }
            input = input.dropFirst()
            return first
        }

        func serialize(_ output: Character, into buffer: inout Substring) throws(Mismatch) {
            guard output.isNumber else { throw .mismatch }
            buffer.append(output)
        }
    }

    private struct LeadingMarker: Coding {
        typealias Failure = Mismatch

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, String, Substring, Mismatch> {
            Marker("<")
            Constant("tag")
        }
    }

    private struct TrailingMarker: Coding {
        typealias Failure = Mismatch

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, String, Substring, Mismatch> {
            Constant("tag")
            Marker(">")
        }
    }

    private struct KeyValue: Coding {
        typealias Failure = Mismatch

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, Pair<String, String>, Substring, Mismatch> {
            Constant("k")
            Marker("=")
            Constant("v")
        }
    }

    private struct Wide: Coding {
        func parse(_ input: inout Substring) throws(Mismatch) -> Int32 {
            guard let first = input.first, let digit = first.wholeNumberValue else { throw .mismatch }
            input = input.dropFirst()
            return Int32(digit)
        }

        func serialize(_ output: Int32, into buffer: inout Substring) throws(Mismatch) {
            guard (0...9).contains(output) else { throw .mismatch }
            buffer.append(contentsOf: String(output))
        }
    }

    private struct Narrow: Coding {
        func parse(_ input: inout Substring) throws(Mismatch) -> Int8 {
            guard let first = input.first, let digit = first.wholeNumberValue else { throw .mismatch }
            input = input.dropFirst()
            return Int8(digit)
        }

        func serialize(_ output: Int8, into buffer: inout Substring) throws(Mismatch) {
            guard (0...9).contains(output) else { throw .mismatch }
            buffer.append(contentsOf: String(output))
        }
    }

    private struct Bracketed: Coding {
        typealias Failure = Mismatch

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, String, Substring, Mismatch> {
            Coder::Coder {
                Marker("<")
                Constant("tag")
                Marker(">")
            }
        }
    }

    private struct NativelySequenced: Coding {
        typealias Failure = Mismatch

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, String, Substring, Mismatch> {
            Coder::Coder {
                Marker("<")
                Constant("tag")
                Marker(">")
            }
        }
    }

    private struct Renamed: Coding {
        typealias Failure = Domain

        @Coder::Builder<Substring, Substring>
        var body: some Coding<Substring, String, Substring, Domain> {
            Constant("tag").mapFailure { _ in Domain.malformed }
        }
    }

    private struct Boxed: Equatable {
        var value: Character
    }

    extension Boxed {
        struct Coder: Coding {
            typealias Failure = Mismatch

            @Coder::Builder<Substring, Substring>
            var body: some Coding<Substring, Boxed, Substring, Mismatch> {
                Coder::Coder {
                    Marker("(")
                    Digit()
                    Marker(")")
                }
                .map(to: { Boxed(value: $0) }, from: { $0.value })
            }
        }
    }

    @Suite
    struct `Coders parse and serialize nonescaping inputs with typed failures` {

        @Test
        func `a coder body parses from a nonescapable cursor and serializes into a buffer`() throws(any Swift
            .Error)
        {
            var buffer: [UInt8] = []
            try FramedDigit().serialize(0x37, into: &buffer)
            #expect(buffer == [0x28, 0x37, 0x29])
            var cursor = Cursor(buffer.span)
            let parsed = try FramedDigit().parse(&cursor)
            let end = cursor.index
            #expect(parsed == 0x37)
            #expect(end == 3)
        }

        @Test
        func `a coder body over a nonescapable cursor reports the leaf failure`() {
            let bytes: [UInt8] = [0x28, 0x41, 0x29]
            var cursor = Cursor(bytes.span)
            var failure: ByteMismatch?
            do {
                _ = try FramedDigit().parse(&cursor)
            } catch {
                failure = error
            }
            #expect(failure == .expected(0x30))
        }
    }

    private struct Cursor: ~Escapable {
        var span: Span<UInt8>
        var index: Int

        @_lifetime(copy span)
        init(_ span: Span<UInt8>) {
            self.span = span
            self.index = 0
        }
    }

    private enum ByteMismatch: Swift.Error, Equatable {
        case expected(UInt8)
        case endOfInput
    }

    private struct ByteMarker: Coding {
        let expected: UInt8

        init(_ expected: UInt8) {
            self.expected = expected
        }

        borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) {
            guard input.index < input.span.count else { throw .endOfInput }
            guard input.span[input.index] == expected else { throw .expected(expected) }
            input.index += 1
        }

        borrowing func serialize(_ output: Void, into buffer: inout [UInt8]) throws(ByteMismatch) {
            buffer.append(expected)
        }
    }

    private struct ByteDigit: Coding {
        borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) -> UInt8 {
            guard input.index < input.span.count else { throw .endOfInput }
            let byte = input.span[input.index]
            guard (0x30...0x39).contains(byte) else { throw .expected(0x30) }
            input.index += 1
            return byte
        }

        borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) throws(ByteMismatch) {
            guard (0x30...0x39).contains(output) else { throw .expected(0x30) }
            buffer.append(output)
        }
    }

    private struct FramedDigit: Coding {
        typealias Failure = ByteMismatch

        @Coder::Builder<Cursor, [UInt8]>
        var body: some Coding<Cursor, UInt8, [UInt8], ByteMismatch> {
            ByteMarker(0x28)
            ByteDigit()
            ByteMarker(0x29)
        }
    }

#endif
