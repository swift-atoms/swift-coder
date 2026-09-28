#if Byte
import Byte
import Coder
import Testing

@Suite
struct `String Coder` {

    @Test
    func `a string round trips through its UTF-8 bytes`() throws(any Swift.Error) {
        let coder = Swift.String.Coder()
        var buffer: [Byte] = []
        try coder.serialize("café", into: &buffer)
        #expect(buffer == Array(utf8: "café"))

        var input = buffer[...]
        #expect(try coder.parse(&input) == "café")
        #expect(input.isEmpty)
    }

    @Test
    func `bytes that are not valid UTF-8 are rejected`() {
        var input: ArraySlice<Byte> = [Byte(bitPattern: 0xFF)]
        #expect(throws: Swift.String.Coder.Error.invalid) {
            try Swift.String.Coder().parse(&input)
        }
    }

    @Test
    func `the coder reads every remaining byte`() throws(any Swift.Error) {
        var input: ArraySlice<Byte> = "one two"
        #expect(try Swift.String.Coder().parse(&input) == "one two")
        #expect(input.isEmpty)
    }

    @Test
    func `a lossless value round trips through its text form`() throws(any Swift.Error) {
        let coder = Swift.String.Coder.Lossless<Int>()

        var buffer: [Byte] = []
        try coder.serialize(42, into: &buffer)
        #expect(buffer == Array(utf8: "42"))

        var input = buffer[...]
        #expect(try coder.parse(&input) == 42)
    }

    @Test
    func `text that is not a value of the coded type is rejected`() {
        let coder = Swift.String.Coder.Lossless<Int>()
        var input: ArraySlice<Byte> = "x"
        #expect(throws: Swift.String.Coder.Error.malformed) {
            try coder.parse(&input)
        }
    }
}
#endif
