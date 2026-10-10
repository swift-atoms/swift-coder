#if Operation
import Coder
import Operation
import Optic
import Parser
import Serializer
import Testing

@Suite
struct `Operation Coder` {

    @Test
    func `a case keyed by its key path round trips a call`() throws(any Swift.Error) {
        let coder = Coder::Case(\Fixture.Call.Cases.echo, absent: Mismatch.absent) {
            Word.Coder()
        }

        var buffer: Substring = ""
        try coder.serialize(.echo(Word("Ada")), into: &buffer)
        #expect(buffer == "word:Ada")

        var input = buffer
        guard case .echo(let application) = try coder.parse(&input) else {
            Issue.record("expected the echo case")
            return
        }
        #expect(application.input == Word("Ada"))
    }

    @Test
    func `each case of a coproduct keys its own coder`() throws(any Swift.Error) {
        let coder = Coder::Case(\Fixture.Call.Cases.shout, absent: Mismatch.absent) {
            Word.Coder()
        }

        var buffer: Substring = ""
        try coder.serialize(.shout(Word("Grace")), into: &buffer)
        #expect(buffer == "word:Grace")

        var input = buffer
        guard case .shout(let application) = try coder.parse(&input) else {
            Issue.record("expected the shout case")
            return
        }
        #expect(application.input == Word("Grace"))
    }

    @Test
    func `a case keyed by its optic case takes its content as a value`() throws(any Swift.Error) {
        let coder = Coder::Case(
            Fixture.Call.cases.echo,
            absent: Mismatch.absent,
            content: Word.Coder()
        )

        var buffer: Substring = ""
        try coder.serialize(.echo(Word("Alan")), into: &buffer)
        #expect(buffer == "word:Alan")
    }

    @Test
    func `serializing a call the case does not match throws the absent failure`() {
        let coder = Coder::Case(\Fixture.Call.Cases.echo, absent: Mismatch.absent) {
            Word.Coder()
        }

        var buffer: Substring = ""
        #expect(throws: Mismatch.absent) {
            try coder.serialize(.shout(Word("Ada")), into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `an application coder lifts a content coder to the operation's application`()
        throws(any Swift.Error)
    {
        let coder = Operation.Application<Fixture.Operations.Echo>.Coder(Word.Coder())

        var buffer: Substring = ""
        try coder.serialize(.init(Word("Ada")), into: &buffer)
        #expect(buffer == "word:Ada")

        var input = buffer
        #expect(try coder.parse(&input).input == Word("Ada"))
    }
}

enum Fixture {

    enum Operations {

        enum Echo: Operation.Symbol {

            typealias Input = Word

            typealias Output = Word

            typealias Failure = Never

            typealias Application = Operation.Application<Self>
        }

        enum Shout: Operation.Symbol {

            typealias Input = Word

            typealias Output = Word

            typealias Failure = Never

            typealias Application = Operation.Application<Self>
        }
    }

    enum Call: Operation.Coproduct {

        case echo(Fixture.Operations.Echo.Application)
        case shout(Fixture.Operations.Shout.Application)

        typealias Owner = Void

        static func run(_ owner: Void, _ call: consuming Self) async throws {}

        static func echo(_ word: Word) -> Self {
            .echo(Fixture.Operations.Echo.Application(word))
        }

        static func shout(_ word: Word) -> Self {
            .shout(Fixture.Operations.Shout.Application(word))
        }

        struct Cases {

            var echo: Optic<
                Fixture.Call,
                Fixture.Call,
                Fixture.Operations.Echo.Application,
                Fixture.Operations.Echo.Application
            >.Case {
                .init(
                    Optic<
                        Fixture.Call,
                        Fixture.Call,
                        Fixture.Operations.Echo.Application,
                        Fixture.Operations.Echo.Application
                    >.Prism(
                        embed: { application in Fixture.Call.echo(application) },
                        extract: { call in
                            guard case .echo(let application) = call else { return nil }
                            return application
                        }
                    )
                )
            }

            var shout: Optic<
                Fixture.Call,
                Fixture.Call,
                Fixture.Operations.Shout.Application,
                Fixture.Operations.Shout.Application
            >.Case {
                .init(
                    Optic<
                        Fixture.Call,
                        Fixture.Call,
                        Fixture.Operations.Shout.Application,
                        Fixture.Operations.Shout.Application
                    >.Prism(
                        embed: { application in Fixture.Call.shout(application) },
                        extract: { call in
                            guard case .shout(let application) = call else { return nil }
                            return application
                        }
                    )
                )
            }
        }

        static var cases: Cases {
            Cases()
        }
    }
}

struct Word: Equatable {

    let text: String

    init(_ text: String) {
        self.text = text
    }

    struct Coder: Coding {


        typealias Input = Substring

        typealias Output = Word

        typealias Buffer = Substring

        typealias Failure = Mismatch

        func parse(_ input: inout Substring) throws(Mismatch) -> Word {
            guard input.hasPrefix("word:") else { throw .absent }
            let text = input.dropFirst("word:".count)
            input = ""
            return Word(Swift.String(text))
        }

        func serialize(_ output: Word, into buffer: inout Substring) throws(Mismatch) {
            buffer.append(contentsOf: "word:")
            buffer.append(contentsOf: output.text)
        }
    }
}

enum Mismatch: Swift.Error, Equatable {
    case absent
    case malformed
}

extension `Operation Coder` {
    @Test func `application lift preserves noncopyable cursor and buffer`() {
        let coder = Operation.Application<Fixture.Operations.Echo>.Coder(OwnedStorageCoder())
        var input = OwnedCursor(text: "Ada")
        let application = coder.parse(&input)
        #expect(application.input == Word("Ada"))
        #expect(input.text.isEmpty)
        var buffer = OwnedBuffer()
        coder.serialize(application, into: &buffer)
        coder.serialize(application, into: &buffer)
        #expect(buffer.text == "AdaAda")
        #expect(application.input == Word("Ada"))
    }

    @Test func `application lift propagates content rejection without consuming input`() {
        let coder = Operation.Application<Fixture.Operations.Echo>.Coder(Word.Coder())
        var input: Substring = "other:Ada"
        #expect(throws: Mismatch.absent) { try coder.parse(&input) }
        #expect(input == "other:Ada")
    }
}

private struct OwnedCursor: ~Copyable { var text: Substring }
private struct OwnedBuffer: ~Copyable { var text: String = "" }
private struct OwnedStorageCoder: Coding {

    borrowing func parse(_ input: inout OwnedCursor) -> Word {
        let value = Word(String(input.text))
        input.text = ""
        return value
    }
    borrowing func serialize(_ output: borrowing Word, into buffer: inout OwnedBuffer) {
        buffer.text += output.text
    }
}
#endif
