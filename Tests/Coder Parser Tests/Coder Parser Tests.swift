import Coder_Parser
import Pair
import Pair_Parser
import Parser_Match
import Parser_Skip
import Testing

@Suite
struct Test {

    struct Constant: Coder.`Protocol`, Parser.Bidirectional {

        typealias Body = Never

        let text: String

        init(_ text: String) {
            self.text = text
        }

        enum Failure: Swift.Error {
            case mismatch
        }

        func parse(_ input: inout Substring) throws(Failure) -> String {
            guard input.hasPrefix(text) else { throw .mismatch }
            input = input.dropFirst(text.count)
            return text
        }

        func serialize(_ output: String, into buffer: inout Substring) throws(Failure) {
            guard output == text else { throw .mismatch }
            buffer.append(contentsOf: text)
        }
    }

    @Suite
    struct Unit {
        @Test
        func `String literal serializes by appending`() throws {
            var buffer: Substring = ""
            "id=".serialize((), into: &buffer)
            #expect(buffer == "id=")
        }

        @Test
        func `a pair of serializers serializes children in forward order`() throws {
            let coder = Pair("a=", "1")
            var buffer: Substring = ""
            try coder.serialize(((), ()), into: &buffer)
            #expect(buffer == "a=1")
        }

        @Test
        func `Skip pair round-trips`() throws {
            let coder = Parser.Skip.First("<", Test.Constant("tag"))
            var buffer: Substring = ""
            try coder.serialize("tag", into: &buffer)
            #expect(buffer == "<tag")
            var cursor = buffer
            let parsed = try coder.parse(&cursor)
            #expect(parsed == "tag")
            #expect(cursor.isEmpty)
        }

        @Test
        func `a constant coder carries a value through check-then-emit`() throws {
            let coder = Test.Constant("abc")
            var buffer: Substring = ""
            try coder.serialize("abc", into: &buffer)
            #expect(buffer == "abc")
            var cursor = buffer
            #expect(try coder.parse(&cursor) == "abc")
            #expect(cursor.isEmpty)
        }
    }

    @Suite
    struct `Edge Case` {
        @Test
        func `serialize mismatch throws and appends nothing`() throws {

            let coder = Test.Constant("a")
            var buffer: Substring = "prefix:"
            #expect(throws: (any Swift.Error).self) {
                try coder.serialize("b", into: &buffer)
            }
            #expect(buffer == "prefix:")
        }
    }

    @Suite
    struct Integration {
        @Test
        func `non-empty-rest law, append orientation`() throws {

            let head = Pair("user/", "7")
            let tail = Parser.Skip.First("?q=", Test.Constant("abc"))

            var buffer: Substring = ""
            try head.serialize(((), ()), into: &buffer)
            try tail.serialize("abc", into: &buffer)
            #expect(buffer == "user/7?q=abc")

            var cursor = buffer
            _ = try Pair("user/", "7").parser().parse(&cursor)
            #expect(try tail.parse(&cursor) == "abc")
            #expect(cursor.isEmpty)
        }

        @Test
        func `Bidirectional refinement resolves for the B2-17 set`() throws {

            func requiresBidirectional<C: Parser.Bidirectional>(_ coder: C) -> C { coder }
            let skip = requiresBidirectional(Parser.Skip.First("<", Test.Constant("x")))
            var buffer: Substring = ""
            try skip.serialize("x", into: &buffer)
            var cursor = buffer
            #expect(try skip.parse(&cursor) == "x")
            #expect(cursor.isEmpty)
        }
    }
}
