#if Repetition && Checkpoint && Predicate
    import Coder
    import Testing

    @Suite struct RepetitionAndOptionalTests {
        enum Failure: Error, Equatable {
            case absent, fatal, insufficient, excessive, empty, noProgress, overflow, trailing
        }
        struct Digit: Coding {
            func parse(_ input: inout Substring) throws(Failure) -> Int {
                guard let first = input.first else { throw .absent }
                input.removeFirst()
                if first == "!" { throw .fatal }
                guard first >= "0", first <= "9", let value = first.wholeNumberValue else { throw .absent }
                return value
            }
            func serialize(_ output: Int, into buffer: inout String) throws(Failure) {
                guard (0...9).contains(output) else { throw .absent }
                buffer.append(contentsOf: String(output))
            }
        }
        struct Comma: Coding {
            func parse(_ input: inout Substring) throws(Failure) {
                guard input.first == "," else { throw .absent }
                input.removeFirst()
            }
            func serialize(_ output: Void, into buffer: inout String) throws(Failure) { buffer.append(",") }
        }
        static func failure<B, O>(_ error: Repetition<B, O>.Error) -> Failure {
            switch error {
            case .insufficient: .insufficient
            case .excessive: .excessive
            case .emptyBounds: .empty
            case .noProgress: .noProgress
            case .countOverflow: .overflow
            }
        }
        static var list: some Coding<Substring, [Int], String, Failure> {
            return Repetition((1...3), operation: Digit()).coder(
                separatedBy: Comma(), rejected: { $0 == .absent }, failure: failure
            )
        }
        @Test func separatedListRoundTrips() throws {
            var input: Substring = "1,2,3"
            let values = try Self.list.parse(&input)
            #expect(values == [1, 2, 3])
            #expect(input.isEmpty)
            var output = ""
            try Self.list.serialize(values, into: &output)
            #expect(output == "1,2,3")
        }
        @Test func minimumAndMaximumValidateBeforeSerialization() {
            for (values, failure) in [([], Failure.insufficient), ([1, 2, 3, 4], Failure.excessive)] {
                var buffer = "prefix:"
                #expect(throws: failure) { try Self.list.serialize(values, into: &buffer) }
                #expect(buffer == "prefix:")
            }
            var input: Substring = "xrest"
            #expect(throws: Failure.insufficient) { try Self.list.parse(&input) }
            #expect(input == "xrest")
        }
        @Test func maximumIsAPrefixBoundaryAndWholeRejectsExtra() throws {
            var input: Substring = "1,2,3,4"
            #expect(try Self.list.parse(&input) == [1, 2, 3])
            #expect(input == ",4")
            #expect(throws: Failure.trailing) { try Self.list.parseAll("1,2,3,4", or: .trailing) }
        }
        @Test func rejectedElementRestoresSeparatorAndConsumedElement() throws {
            for wire in ["1,", "1,xrest"] {
                var input = Substring(wire)
                #expect(try Self.list.parse(&input) == [1])
                #expect(input == wire.dropFirst())
            }
        }
        @Test func fatalElementRemainsConsumed() {
            var input: Substring = "1,!tail"
            #expect(throws: Failure.fatal) { try Self.list.parse(&input) }
            #expect(input == "tail")
        }
        @Test func zeroWidthElementIsRejectedInsteadOfLooping() {
            let zero = Coder<Substring, Int, String, Failure>(
                parse: { _ throws(Failure) in 0 }, serialize: { _, _ throws(Failure) in }
            )
            let coder = Repetition((0...), operation: zero).coder(
                rejected: { $0 == .absent }, failure: Self.failure)
            var input: Substring = "unchanged"
            #expect(throws: Failure.noProgress) { try coder.parse(&input) }
            #expect(input == "unchanged")
        }
        @Test func emptyBoundsFailBothWays() {
            let coder = Repetition((2..<2), operation: Digit()).coder(
                rejected: { $0 == .absent }, failure: Self.failure)
            var input: Substring = "123"
            #expect(throws: Failure.empty) { try coder.parse(&input) }
            #expect(input == "123")
            var output = "prefix:"
            #expect(throws: Failure.empty) { try coder.serialize([1, 2], into: &output) }
            #expect(output == "prefix:")
        }
        @Test func optionalRestoresRejectionAndPropagatesFatal() throws {
            let coder = Digit().optional(rejected: { $0 == .absent })
            var rejected: Substring = "xrest"
            #expect(try coder.parse(&rejected) == nil)
            #expect(rejected == "xrest")
            var present: Substring = "7rest"
            #expect(try coder.parse(&present) == 7)
            #expect(present == "rest")
            var fatal: Substring = "!rest"
            #expect(throws: Failure.fatal) { try coder.parse(&fatal) }
            #expect(fatal == "rest")
        }
        @Test func optionalPresentSerializationNeverTurnsFailureIntoAbsence() throws {
            let coder = Digit().optional(rejected: { $0 == .absent })
            var output = "prefix:"
            try coder.serialize(nil, into: &output)
            #expect(output == "prefix:")
            #expect(throws: Failure.absent) { try coder.serialize(99, into: &output) }
            #expect(output == "prefix:")
            try coder.serialize(7, into: &output)
            #expect(output == "prefix:7")
        }
        @Test func predicatesValidateBothDirections() throws {
            let coder = Digit().filter(Predicate { $0 < 5 }, failure: .fatal)
            var input: Substring = "7rest"
            #expect(throws: Failure.fatal) { try coder.parse(&input) }
            #expect(input == "rest")
            var output = "prefix:"
            #expect(throws: Failure.fatal) { try coder.serialize(7, into: &output) }
            #expect(output == "prefix:")
            try coder.serialize(4, into: &output)
            #expect(output == "prefix:4")
        }
    }
#endif
