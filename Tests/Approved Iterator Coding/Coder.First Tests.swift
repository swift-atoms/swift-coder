#if IteratorLeaves && Pair && Skip && Map && Either
import Coder
import Either
import Iterator
import Coder
import Parser
import Parser
import Serializer
import Testing

@Suite
struct `Coder::First Tests` {

    @Test
    func `Element serializes the given element`() {
        var buffer = "a"
        Coder::First.Element<Characters, String>().serialize("b", into: &buffer)
        #expect(buffer == "ab")
    }

    @Test
    func `Element parses the first element`() throws(any Swift.Error) {
        var input = Characters("ab")
        #expect(try Coder::First.Element<Characters, String>().parse(&input) == "a")
        #expect(input.remainder == "b")
    }

    @Test
    func `Where refuses to serialize an element its predicate rejects`() {
        var buffer = ""
        #expect(throws: Coder::First.Where<Characters, String>.Failure.right(.predicateFailed(expected: "letter"))) {
            try Coder::First.Where<Characters, String>(expected: "letter", \.isLetter).serialize("1", into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `a coder body lifts a literal and infers the leaves from the builder`() throws(any Swift.Error) {
        var buffer = ""
        try Framed().serialize("x", into: &buffer)
        #expect(buffer == "[x]")

        var input = Characters(buffer)
        #expect(try Framed().parse(&input) == "x")
        #expect(input.remainder.isEmpty)
    }

    @Test
    func `a coder body reports a literal mismatch through the array parser`() {
        var input = Characters("(x]")
        #expect(throws: Framed.Failure.self) {
            try Framed().parse(&input)
        }
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

private struct Framed: Coding {
    typealias Failure = Either<
        Either<Parser::ConsumingLiteral<Characters>.Error, Parser::EndOfInput.Error>,
        Parser::ConsumingLiteral<Characters>.Error
    >

    @Coder::Builder<Characters, String>
    var body: some Coding<Characters, Character, String, Failure> {
        Coder::ConsumingLiteral<Characters, String>(["["])
        Coder::First.Element()
        Coder::ConsumingLiteral<Characters, String>(["]"])
    }
}
#endif
