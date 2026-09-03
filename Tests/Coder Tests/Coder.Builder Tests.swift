import Coder
import Either
import Parser
import Parser_Skip
import Serializer
import Testing

@Suite
struct `Coder.Builder Tests` {

    @Test
    func `a coder body skips a trailing marker`() throws(any Swift.Error) {
        var buffer = ""
        try Trailing().serialize("tag", into: &buffer)
        #expect(buffer == "tag>")

        var input: Substring = "tag>"
        #expect(try Trailing().parse(&input) == "tag")
        #expect(input.isEmpty)
    }

    @Test
    func `a coder body appends two outputs`() throws(any Swift.Error) {
        var buffer = ""
        try Pairing().serialize(("a", "b"), into: &buffer)
        #expect(buffer == "ab")

        var input: Substring = "ab"
        let (first, second) = try Pairing().parse(&input)
        #expect(first == "a")
        #expect(second == "b")
        #expect(input.isEmpty)
    }

    @Test
    func `a coder body keeps a shared failure`() {
        var input: Substring = "tag)"
        #expect(throws: Mismatch.mismatch) {
            try Trailing().parse(&input)
        }
    }
}

private enum Mismatch: Swift.Error, Equatable {
    case mismatch
}

private struct Text: Coder.`Protocol` {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    func parse(_ input: inout Substring) throws(Mismatch) -> String {
        guard input.hasPrefix(text) else { throw .mismatch }
        input.removeFirst(text.count)
        return text
    }

    func serialize(_ output: String, into buffer: inout String) throws(Mismatch) {
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
        input.removeFirst(text.count)
    }

    func serialize(_ output: Void, into buffer: inout String) throws(Mismatch) {
        buffer.append(contentsOf: text)
    }
}

private struct Trailing: Coder.`Protocol` {
    typealias Failure = Mismatch

    @Coder.Builder<Substring, String>
    var body: some Coding<Substring, String, String, Mismatch> {
        Text("tag")
        Marker(">")
    }
}

private struct Pairing: Coder.`Protocol` {
    typealias Failure = Mismatch

    @Coder.Builder<Substring, String>
    var body: some Coding<Substring, (String, String), String, Mismatch> {
        Text("a")
        Text("b")
    }
}
