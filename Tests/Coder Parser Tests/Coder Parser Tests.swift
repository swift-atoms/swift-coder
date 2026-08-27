import Coder_Parser
import Testing

@Suite
struct Test {

    static func constant(
        _ text: String
    ) -> Parser.Converted<String, Parser.Conversion.Witness<Void, String, Parser.Conversion.Error>>
    {
        Parser.Converted(
            upstream: text,
            downstream: Parser.Conversion.Witness<Void, String, Parser.Conversion.Error>(
                apply: { _ in text },
                unapply: { (value: String) throws(Parser.Conversion.Error) in
                    guard value == text else { throw .absentCase }
                    return ()
                }
            )
        )
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
        func `Take Two serializes children in forward order`() throws {
            let coder = Parser.Take.Two("a=", "1")
            var buffer: Substring = ""
            try coder.serialize(((), ()), into: &buffer)
            #expect(buffer == "a=1")
        }

        @Test
        func `Skip pair round-trips`() throws {
            let coder = Parser.Skip.First("<", Test.constant("tag"))
            var buffer: Substring = ""
            try coder.serialize("tag", into: &buffer)
            #expect(buffer == "<tag")
            var cursor = buffer
            let parsed = try coder.parse(&cursor)
            #expect(parsed == "tag")
            #expect(cursor.isEmpty)
        }

        @Test
        func `Converted carries a value through unapply-then-emit`() throws {
            let coder = Test.constant("abc")
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
        func `unapply mismatch throws and appends nothing`() throws {

            let coder = Test.constant("a")
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

            let head = Parser.Take.Two("user/", "7")
            let tail = Parser.Skip.First("?q=", Test.constant("abc"))

            var buffer: Substring = ""
            try head.serialize(((), ()), into: &buffer)
            try tail.serialize("abc", into: &buffer)
            #expect(buffer == "user/7?q=abc")

            var cursor = buffer
            _ = try head.parse(&cursor)
            #expect(try tail.parse(&cursor) == "abc")
            #expect(cursor.isEmpty)
        }

        @Test
        func `Bidirectional refinement resolves for the B2-17 set`() throws {

            func requiresBidirectional<C: Parser.Bidirectional>(_ coder: C) -> C { coder }
            let skip = requiresBidirectional(Parser.Skip.First("<", Test.constant("x")))
            var buffer: Substring = ""
            try skip.serialize("x", into: &buffer)
            var cursor = buffer
            #expect(try skip.parse(&cursor) == "x")
            #expect(cursor.isEmpty)
        }
    }
}
