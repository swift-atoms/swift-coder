#if Byte
import Byte
import Coder
import Parser
import Serializer
import Testing

@Suite
struct `Byte Coder` {

    @Test
    func `an explicit byte coder round trips over the canonical carrier`() throws(any Swift.Error) {
        let coder = Digit.Coder()
        var buffer: [Byte] = []
        try coder.serialize(Digit(7), into: &buffer)
        #expect(buffer == "7")

        var input = buffer[...]
        #expect(try coder.parse(&input) == Digit(7))
        #expect(input.isEmpty)
    }

    @Test
    func `a byte coding is spelled with its output and failure alone`() throws(any Swift.Error) {
        let coder: some Byte.Coding<Digit, Digit.Error> = Digit.Coder()
        var buffer: [Byte] = []
        try coder.serialize(Digit(4), into: &buffer)
        #expect(buffer == "4")
    }

    @Test
    func `the never coder rejects every input and consumes nothing`() {
        var input: ArraySlice<Byte> = "anything"
        #expect(throws: Swift.Never.Coder.Error.absent) {
            try Swift.Never.Coder().parse(&input)
        }
        #expect(input == "anything")
    }

    @Test
    func `the never coder is reachable through the canonical carrier`() {
        let coder: some Byte.Coding<Swift.Never, Swift.Never.Coder.Error> = Swift.Never.Coder()
        var input: ArraySlice<Byte> = []
        #expect(throws: Swift.Never.Coder.Error.absent) {
            try coder.parse(&input)
        }
    }

    @Test
    func `a value outside the coded range is rejected`() {
        var input: ArraySlice<Byte> = "x"
        #expect(throws: Digit.Error.notADigit) {
            try Digit.Coder().parse(&input)
        }
    }
}

struct Digit: Equatable {

    let value: Int

    init(_ value: Int) {
        self.value = value
    }

    enum Error: Swift.Error, Equatable {
        case notADigit
    }

    struct Coder: Coding {
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
            }
        }


        typealias Input = ArraySlice<Byte>

        typealias Output = Digit

        typealias Buffer = [Byte]

        typealias Failure = Digit.Error

        func parse(_ input: inout ArraySlice<Byte>) throws(Digit.Error) -> Digit {
            guard let byte = input.popFirst(), (0x30...0x39).contains(byte.bitPattern) else {
                throw .notADigit
            }
            return Digit(Int(byte.bitPattern - 0x30))
        }

        func serialize(_ output: Digit, into buffer: inout [Byte]) throws(Digit.Error) {
            guard (0...9).contains(output.value) else { throw .notADigit }
            buffer.append(Byte(bitPattern: UInt8(0x30 + output.value)))
        }
    }

}
#endif
