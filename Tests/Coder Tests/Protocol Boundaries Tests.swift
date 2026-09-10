import Coder
import Testing
import User_Records_Model

#if Pair && Skip && Map

private enum RequestExample {
    struct Header: Equatable { var name: String; var value: String }
    struct Request: Equatable {
        var method = ""
        var target = ""
        var headers: [Header] = []
        var content: [UInt8]?
        var trailers: [Header] = []
    }
    struct CreateUser: Equatable { var user: User }
    enum Failure: Error, Equatable {
        case mismatch
        case missingBody
        case invalidUTF8
        case malformed(RecordFailure)
        case unprintable(RecordFailure)
    }

    struct Method: Coding {
        var expected: String
        func parse(_ input: inout Request) throws(Failure) {
            guard input.method == expected else { throw .mismatch }
        }
        func serialize(_ output: borrowing Void, into buffer: inout Request) throws(Failure) {
            buffer.method = expected
        }
    }
    struct Target: Coding {
        var expected: String
        func parse(_ input: inout Request) throws(Failure) {
            guard input.target == expected else { throw .mismatch }
        }
        func serialize(_ output: borrowing Void, into buffer: inout Request) throws(Failure) {
            buffer.target = expected
        }
    }
    struct Content: Coding {
        func parse(_ input: inout Request) throws(Failure) -> User {
            guard let bytes = input.content else { throw .missingBody }
            guard let text = String(validating: bytes, as: UTF8.self) else { throw .invalidUTF8 }
            let value: User
            do throws(RecordFailure) { value = try User.Coder().whole(text[...]) }
            catch { throw .malformed(error) }
            input.content = nil
            return value
        }
        func serialize(_ output: borrowing User, into buffer: inout Request) throws(Failure) {
            var text = ""
            do throws(RecordFailure) { try User.Coder().serialize(output, into: &text) }
            catch { throw .unprintable(error) }
            buffer.content = Array(text.utf8)
        }
    }
    struct Route: Coding {
        var body: some Coding<Request, CreateUser, Request, Failure> {
            return Coder(
                { user throws(Failure) in CreateUser(user: user) },
                from: { route throws(Failure) in route.user }
            ) {
                Method(expected: "POST")
                Target(expected: "/users")
                Content()
            }
        }
    }

    static func request(for value: borrowing CreateUser) throws(Failure) -> Request {
        var result = Request()
        try Route().serialize(value, into: &result)
        return result
    }
}

@Suite struct `HTTP request boundary fixture` {
    @Test func `route construction retains both directions`() throws {
        let value = RequestExample.CreateUser(user: User(name: "Zoë Smith", age: 42))
        let request = try RequestExample.request(for: value)
        #expect(request.method == "POST")
        #expect(request.target == "/users")
        #expect(request.content == Array("Zoë Smith,42\n".utf8))
        var input = request
        #expect(try RequestExample.Route().parse(&input) == value)
        #expect(input.content == nil)
    }

    @Test func `request normalization does not preserve absent model information`() throws {
        let original = RequestExample.Request(
            method: "POST", target: "/users",
            headers: [.init(name: "X-Trace", value: "first"), .init(name: "X-Trace", value: "second")],
            content: Array("Alice,0042\n".utf8),
            trailers: [.init(name: "X-Checksum", value: "abc")]
        )
        var input = original
        let route = try RequestExample.Route().parse(&input)

        #expect(input.headers == original.headers)
        #expect(input.trailers == original.trailers)
        let canonical = try RequestExample.request(for: route)
        #expect(canonical.content == Array("Alice,42\n".utf8))
        #expect(canonical.headers.isEmpty && canonical.trailers.isEmpty)
        #expect(canonical != original)
    }

    @Test func `a recognized request requires a complete valid UTF8 body`() {
        let cases: [([UInt8]?, RequestExample.Failure)] = [
            (nil, .missingBody),
            ([0xFF], .invalidUTF8),
            (Array("Alice,42\nextra".utf8), .malformed(.trailingInput)),
            (Array("Alice,131\n".utf8), .malformed(.invalidAge("131"))),
            (Array("Alice,42\r\n".utf8), .malformed(.rejected)),
        ]
        for (bytes, error) in cases {
            var request = RequestExample.Request(method: "POST", target: "/users", content: bytes)
            let original = request
            #expect(throws: error) { try RequestExample.Route().parse(&request) }
            #expect(request == original)
        }
    }

    @Test func `selection mismatch differs from an invalid printable body`() {
        var wrong = RequestExample.Request(method: "GET", target: "/users")
        #expect(throws: RequestExample.Failure.mismatch) { try RequestExample.Route().parse(&wrong) }
        let invalid = RequestExample.CreateUser(user: User(name: "Alice", age: 131))
        #expect(throws: RequestExample.Failure.unprintable(.invalidAge("131"))) {
            try RequestExample.request(for: invalid)
        }
    }
}
#endif

private enum PercentExample {
    enum Failure: Error, Equatable { case percent, hexDigit, trailingInput }

    static func hex(_ byte: UInt8) -> UInt8? {
        switch byte {
        case 0x30...0x39: byte - 0x30
        case 0x41...0x46: byte - 0x37
        case 0x61...0x66: byte - 0x57
        default: nil
        }
    }

    static var coder: Coder<ArraySlice<UInt8>, UInt8, [UInt8], Failure> {
        Coder(parse: { input throws(Failure) in

            var remaining = input
            guard remaining.popFirst() == 0x25 else { throw .percent }
            guard let first = remaining.popFirst(), let high = hex(first),
                let second = remaining.popFirst(), let low = hex(second)
            else { throw .hexDigit }
            input = remaining
            return (high << 4) | low
        }, serialize: { byte, buffer throws(Failure) in
            let digits = Array("0123456789ABCDEF".utf8)
            buffer.append(0x25)
            buffer.append(digits[Int(byte >> 4)])
            buffer.append(digits[Int(byte & 0x0F)])
        })
    }

    static func whole(_ input: ArraySlice<UInt8>) throws(Failure) -> UInt8 {
        var remaining = input
        let byte = try coder.parse(&remaining)
        guard remaining.isEmpty else { throw .trailingInput }
        return byte
    }
}

@Suite struct `RFC percent encoding boundary fixture` {
    @Test(arguments: UInt8.min...UInt8.max)
    func `all byte values round trip through canonical spelling`(_ value: UInt8) throws {
        var output: [UInt8] = []
        try PercentExample.coder.serialize(value, into: &output)
        #expect(output.count == 3)
        #expect(try PercentExample.whole(output[...]) == value)
        var second: [UInt8] = []
        try PercentExample.coder.serialize(try PercentExample.whole(output[...]), into: &second)
        #expect(second == output)
    }

    @Test func `prefix and complete input have different contracts`() throws {
        var input = Array("%2f/rest".utf8)[...]
        #expect(try PercentExample.coder.parse(&input) == 0x2F)
        #expect(input.elementsEqual("/rest".utf8))
        #expect(throws: PercentExample.Failure.trailingInput) {
            try PercentExample.whole(Array("%2F/rest".utf8)[...])
        }
        var output: [UInt8] = []
        try PercentExample.coder.serialize(try PercentExample.whole(Array("%2f".utf8)[...]), into: &output)
        #expect(output == Array("%2F".utf8))
    }

    @Test(arguments: ["%", "%2", "%+F", "% F", "%F+", "%G0", "%0g", "%é"])
    func `malformed hex never consumes a partial token`(_ spelling: String) {
        let bytes = Array(spelling.utf8)[...]
        var input = bytes
        #expect(throws: PercentExample.Failure.hexDigit) { try PercentExample.coder.parse(&input) }
        #expect(input == bytes)
    }

    @Test func `wrong leading byte is a lexical rejection`() {
        var input = Array("2F".utf8)[...]
        #expect(throws: PercentExample.Failure.percent) { try PercentExample.coder.parse(&input) }
        #expect(input.elementsEqual("2F".utf8))
    }
}
