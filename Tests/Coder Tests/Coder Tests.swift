import Coder
import Parser
import Parser_Skip
import Serializer
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

    struct Marker: Coder.`Protocol`, Parser.Bidirectional {

        typealias Body = Never

        let text: String

        init(_ text: String) {
            self.text = text
        }

        enum Failure: Swift.Error {
            case mismatch
        }

        func parse(_ input: inout Substring) throws(Failure) {
            guard input.hasPrefix(text) else { throw .mismatch }
            input = input.dropFirst(text.count)
        }

        func serialize(_ output: Void, into buffer: inout Substring) throws(Failure) {
            buffer.append(contentsOf: text)
        }
    }

    @Suite
    struct Unit {
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

        @Test
        func `Skip pair round-trips`() throws {
            let coder = Parser.Skip.First(Test.Marker("<"), Test.Constant("tag"))
            var buffer: Substring = ""
            try coder.serialize("tag", into: &buffer)
            #expect(buffer == "<tag")
            var cursor = buffer
            let parsed = try coder.parse(&cursor)
            #expect(parsed == "tag")
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
        func `Bidirectional refinement resolves for the Skip set`() throws {

            func requiresBidirectional<C: Parser.Bidirectional>(_ coder: C) -> C { coder }
            let skip = requiresBidirectional(
                Parser.Skip.First(Test.Marker("<"), Test.Constant("x"))
            )
            var buffer: Substring = ""
            try skip.serialize("x", into: &buffer)
            var cursor = buffer
            #expect(try skip.parse(&cursor) == "x")
            #expect(cursor.isEmpty)
        }
    }
}
