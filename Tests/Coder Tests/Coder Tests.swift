import Coder
import Parser
import Parser_Error
import Parser_Sequence
import Parser_Skip
import Serializer
import Testing

@Suite
struct `Coder Protocol Tests` {

    @Test
    func `a leaf coder round-trips`() throws(any Swift.Error) {
        try roundTrip(Constant("abc"), "abc", expecting: "abc")
    }

    @Test
    func `a witness coder round-trips`() throws(any Swift.Error) {
        let witness = Coder.Witness<Substring, Character, Substring, Mismatch>(
            parse: { input throws(Mismatch) in
                guard let first = input.first else { throw .mismatch }
                input = input.dropFirst()
                return first
            },
            serialize: { output, buffer in buffer.append(output) }
        )
        try roundTrip(witness, "x", expecting: "x")
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
    func `Sequence round-trips`() throws(any Swift.Error) {
        try roundTrip(Bracketed(), "tag", expecting: "<tag>")
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
    func `Codable adopters encode and decode through their coder`() throws(any Swift.Error) {
        var buffer: Substring = ""
        try Boxed(value: "3").encode(into: &buffer)
        #expect(buffer == "(3)")
        var cursor = buffer
        #expect(try Boxed(decoding: &cursor) == Boxed(value: "3"))
    }
}

private func roundTrip<C: Coder.`Protocol`>(
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

private func roundTrip<C: Coder.`Protocol`>(
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

private func requireFailure<C: Coder.`Protocol`, Failure: Swift.Error>(
    _: borrowing C,
    _: Failure.Type
) where C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable & ~Escapable, C.Buffer: ~Copyable & ~Escapable, C.Failure == Failure {}

private enum Mismatch: Swift.Error, Equatable {
    case mismatch
}

private enum Domain: Swift.Error, Equatable {
    case malformed
}

private struct Constant: Coder.`Protocol` {
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

private struct Marker: Coder.`Protocol` {
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

private struct Digit: Coder.`Protocol` {
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

private struct LeadingMarker: Coder.`Protocol` {
    typealias Failure = Mismatch

    var body: some Coder.`Protocol`<Substring, String, Substring, Mismatch> {
        Marker("<")
        Constant("tag")
    }
}

private struct TrailingMarker: Coder.`Protocol` {
    typealias Failure = Mismatch

    var body: some Coder.`Protocol`<Substring, String, Substring, Mismatch> {
        Constant("tag")
        Marker(">")
    }
}

private struct Bracketed: Coder.`Protocol` {
    typealias Failure = Mismatch

    var body: some Coder.`Protocol`<Substring, String, Substring, Mismatch> {
        Parser.Sequence(Substring.self) {
            Marker("<")
            Constant("tag")
            Marker(">")
        }
    }
}

private struct Renamed: Coder.`Protocol` {
    typealias Failure = Domain

    var body: some Coder.`Protocol`<Substring, String, Substring, Domain> {
        Constant("tag").error.map { _ in Domain.malformed }
    }
}

private struct Boxed: Equatable {
    var value: Character
}

extension Boxed {
    struct Coder: Coding {
        typealias Failure = Mismatch

        var body: some Coding<Substring, Boxed, Substring, Mismatch> {
            Parser.Sequence(Substring.self) {
                Marker("(")
                Digit()
                Marker(")")
            }
            .map(to: { Boxed(value: $0) }, from: { $0.value })
        }
    }
}

extension Boxed: Coder.Codable {
    static var coder: Coder { Coder() }
}
