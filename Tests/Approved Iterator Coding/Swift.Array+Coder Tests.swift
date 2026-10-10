#if IteratorLeaves && Pair && Skip && Map && Either
import Coder
import Coder
import Either
import Iterator
import Coder
import Parser
import Parser
import Serializer
import Testing

@Suite
struct `Swift.Array+Coder Tests` {

    @Test
    func `an array coder serializes by appending`() throws(any Swift.Error) {
        var buffer = ""
        Coder::ConsumingLiteral<Characters, String>(["i", "d", "="]).serialize((), into: &buffer)
        #expect(buffer == "id=")
    }

    @Test
    func `an array coder round-trips as a void coder`() throws(any Swift.Error) {
        let coder = Coder::ConsumingLiteral<Characters, String>(["i", "d", "="])
        var buffer = ""
        coder.serialize((), into: &buffer)
        var cursor = Characters(buffer)
        try coder.parse(&cursor)
        #expect(cursor.remainder.isEmpty)
    }

    @Test
    func `an array coder skips into a constant coder and round-trips`() throws(any Swift.Error) {
        let coder = Tagged()
        var buffer = ""
        try coder.serialize("tag", into: &buffer)
        #expect(buffer == "<tag")
        var cursor = Characters(buffer)
        #expect(try coder.parse(&cursor) == "tag")
        #expect(cursor.remainder.isEmpty)
    }

    @Test
    func `a mismatching literal is the array parser's error`() {
        var cursor = Characters("(tag")
        #expect(
            throws: Either<Parser::ConsumingLiteral<Characters>.Error,
            Mismatch>.left(.mismatch)
        ) {
            try Tagged().parse(&cursor)
        }
    }

    @Test
    func `Codable adopters encode into a fresh buffer`() throws(any Swift.Error) {
        #expect(try Label.Coder().serialize(Label("tag")) == "<tag")
    }
}

private struct Characters: Iterator.`Protocol` {
    var remainder: Substring

    init(_ text: String) {
        remainder = text[...]
    }

    mutating func next() -> Character? {
        remainder.popFirst()
    }
}

private enum Mismatch: Swift.Error, Equatable {
    case mismatch
}

private struct Constant: Coding {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    let text: String

    init(_ text: String) {
        self.text = text
    }

    func parse(_ input: inout Characters) throws(Mismatch) -> String {
        for expected in text {
            guard input.next() == expected else { throw .mismatch }
        }
        return text
    }

    func serialize(_ output: String, into buffer: inout String) throws(Mismatch) {
        guard output == text else { throw .mismatch }
        buffer.append(contentsOf: text)
    }
}

private struct Tagged: Coding {
    typealias Failure = Either<Parser::ConsumingLiteral<Characters>.Error, Mismatch>

    @Coder::Builder<Characters, String>
    var body: some Coding<Characters, String, String, Either<Parser::ConsumingLiteral<Characters>.Error, Mismatch>> {
        Coder::ConsumingLiteral<Characters, String>(["<"])
        Constant("tag")
    }
}

private struct Label: Equatable {
    let text: String

    init(_ text: String) {
        self.text = text
    }
}

extension Label {
    struct Coder: Coding {
        typealias Failure = Either<Parser::ConsumingLiteral<Characters>.Error, Mismatch>

        @Coder::Builder<Characters, String>
    var body: some Coding<Characters, Label, String, Either<Parser::ConsumingLiteral<Characters>.Error, Mismatch>> {
            Tagged().map(to: { Label($0) }, from: { $0.text })
        }
    }

    static var coder: Coder { Coder() }
}
#endif
