import Coder
import Parser
import Serializer
import Testing

enum MatchError: Swift.Error {
    case literalMismatch(expected: String, found: String)
}

@Suite
struct `Coder Witness Dispatch` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    private static func serializeViaWitness<S: Serializer.`Protocol`>(
        _ serializer: borrowing S,
        _ value: S.Output,
        into buffer: inout S.Buffer
    ) throws {
        try serializer.serialize(value, into: &buffer)
    }

    private static func parseViaWitness<P: Parser.`Protocol`>(
        _ parser: borrowing P,
        _ input: inout P.Input
    ) throws -> P.Output where P.Input: ~Copyable & ~Escapable, P.Output: Escapable {
        try parser.parse(&input)
    }

    struct Leaf: Parser.Bidirectional {}

    @Test
    func `leaf coder serializes and parses through witness dispatch`() throws {
        let coder = Leaf()
        var buffer: Substring = ""
        try Self.serializeViaWitness(coder, (), into: &buffer)
        #expect(buffer == "leaf")
        var cursor = buffer
        try Self.parseViaWitness(coder, &cursor)
        #expect(cursor.isEmpty)
    }

    struct Router: Parser.Bidirectional {}

    @Test
    func `body-declaring coder serializes through the serializer-side forwarder without recursing`()
        throws
    {

        let coder = Router()
        var buffer: Substring = ""
        try Self.serializeViaWitness(coder, (), into: &buffer)
        #expect(buffer == "leaf")
        var cursor = buffer
        try Self.parseViaWitness(coder, &cursor)
        #expect(cursor.isEmpty)
    }
}

extension `Coder Witness Dispatch`.Leaf {
    typealias Input = Substring
    typealias Buffer = Substring
    typealias Output = Void

    typealias Failure = MatchError

    func parse(_ input: inout Substring) throws(Failure) {
        guard input.hasPrefix("leaf") else {
            throw .literalMismatch(expected: "leaf", found: String(input))
        }
        input.removeFirst(4)
    }

    borrowing func serialize(_ output: Void, into buffer: inout Substring) throws(Failure) {
        buffer += "leaf"
    }
}

extension `Coder Witness Dispatch`.Router {

    typealias Input = Substring

    typealias Output = Void

    typealias Failure = MatchError

    var body: some Parser.Bidirectional<Substring, Void, MatchError> {
        `Coder Witness Dispatch`.Leaf()
    }
}
