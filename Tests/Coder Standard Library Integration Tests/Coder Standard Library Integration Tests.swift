import Coder
import Coder_Standard_Library_Integration
import Parser
import Parser_Skip
import Parser_Standard_Library_Integration
import Serializer
import Testing

@Suite
struct `Coder Standard Library Integration` {

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
        func `Array literal serializes by appending`() throws {
            var buffer: ArraySlice<Int> = []
            [1, 2, 3].serialize((), into: &buffer)
            #expect(buffer == [1, 2, 3])
        }
    }

    @Suite
    struct `Edge Case` {
        @Test
        func `a nil Optional serializer emits nothing`() throws {
            let serializer: `Coder Standard Library Integration`.Constant? = nil
            var buffer: Substring = "kept"
            try serializer.serialize("anything", into: &buffer)
            #expect(buffer == "kept")
        }
    }

    @Suite
    struct Integration {
        @Test
        func `a String literal skips into a constant coder and round-trips`() throws {
            let coder = Parser.Skip.First("<", `Coder Standard Library Integration`.Constant("tag"))
            var buffer: Substring = ""
            try coder.serialize("tag", into: &buffer)
            #expect(buffer == "<tag")
            var cursor = buffer
            #expect(try coder.parse(&cursor) == "tag")
            #expect(cursor.isEmpty)
        }
    }
}
