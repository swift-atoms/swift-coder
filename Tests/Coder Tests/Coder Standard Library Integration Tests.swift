import Coder
import Coder_Standard_Library_Integration
import Either
import Parser
import Parser_Standard_Library_Integration
import Serializer
import Testing

@Suite
struct `Optional Coder` {

    @Test
    func `a present coder with a present value round-trips`() throws(any Swift.Error) {
        var buffer: Substring = ""
        try Conditional(present: true).serialize("7", into: &buffer)
        #expect(buffer == "7")
        var cursor = buffer
        #expect(try Conditional(present: true).parse(&cursor) == "7")
        #expect(cursor.isEmpty)
    }

    @Test
    func `an absent coder with a nil value round-trips to nothing`() throws(any Swift.Error) {
        var buffer: Substring = ""
        try Conditional(present: false).serialize(nil, into: &buffer)
        #expect(buffer.isEmpty)
        var cursor: Substring = "7"
        #expect(try Conditional(present: false).parse(&cursor) == nil)
        #expect(cursor == "7")
    }

    @Test
    func `a present coder with a nil value is a missing value`() {
        var buffer: Substring = ""
        #expect(throws: Either<Mismatch, Swift.Optional<Digit>.Coder.Error>.right(.missingValue)) {
            try Conditional(present: true).serialize(nil, into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `an absent coder with a present value is an unexpected value`() {
        var buffer: Substring = ""
        #expect(throws: Either<Mismatch, Swift.Optional<Digit>.Coder.Error>.right(.unexpectedValue)) {
            try Conditional(present: false).serialize("7", into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `the wrapped coder's failure is the left branch`() {
        var cursor: Substring = "x"
        #expect(throws: Either<Mismatch, Swift.Optional<Digit>.Coder.Error>.left(.mismatch)) {
            try Conditional(present: true).parse(&cursor)
        }
    }
}

private enum Mismatch: Swift.Error, Equatable {
    case mismatch
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

private struct Conditional: Coder.`Protocol` {
    typealias Failure = Either<Mismatch, Swift.Optional<Digit>.Coder.Error>

    let present: Bool

    var body: some Coding<Substring, Character?, Substring, Either<Mismatch, Swift.Optional<Digit>.Coder.Error>> {
        if present {
            Digit()
        }
    }
}
