import Coder
import Coder_Standard_Library_Integration
import Parser
import Parser_Skip
import Parser_Standard_Library_Integration
import Either
import Serializer
import Testing

@Suite
struct `Coder Standard Library Integration` {

    @Test
    func `a String literal serializes by appending`() throws(any Swift.Error) {
        var buffer: Substring = ""
        try "id=".serialize((), into: &buffer)
        #expect(buffer == "id=")
    }

    @Test
    func `a String literal round-trips as a void coder`() throws(any Swift.Error) {
        var buffer: Substring = ""
        try "id=".serialize((), into: &buffer)
        var cursor = buffer
        try "id=".parse(&cursor)
        #expect(cursor.isEmpty)
    }

    @Test
    func `a String literal skips into a constant coder and round-trips`() throws(any Swift.Error) {
        let coder = Tagged()
        var buffer: Substring = ""
        try coder.serialize("tag", into: &buffer)
        #expect(buffer == "<tag")
        var cursor = buffer
        #expect(try coder.parse(&cursor) == "tag")
        #expect(cursor.isEmpty)
    }

    @Test
    func `Codable adopters encode into a fresh buffer`() throws(any Swift.Error) {
        #expect(try Label("tag").encoded() == "<tag")
    }
}

private enum Mismatch: Swift.Error {
    case mismatch
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

private struct Tagged: Coder.`Protocol` {
    typealias Failure = Either<Parser.Literal.Error, Mismatch>

    var body: some Coder.`Protocol`<Substring, String, Substring, Either<Parser.Literal.Error, Mismatch>> {
        "<"
        Constant("tag")
    }
}

private struct Label: Equatable {
    let text: String

    init(_ text: String) {
        self.text = text
    }
}

extension Label: Coder.Codable {
    struct Coding: Coder.`Protocol` {
        typealias Failure = Either<Parser.Literal.Error, Mismatch>

        var body: some Coder.`Protocol`<Substring, Label, Substring, Either<Parser.Literal.Error, Mismatch>> {
            Tagged().map(to: { Label($0) }, from: { $0.text })
        }
    }

    static var coder: Coding { Coding() }
}
