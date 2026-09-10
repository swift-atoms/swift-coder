#if Optic && Checkpoint && Skip
    import Coder
    import Testing

    @Suite struct OpticAndChoiceTests {
        enum Failure: Error, Equatable {
            case absent, malformed
            case conversion(Conversion)
        }
        enum Conversion: Error, Equatable { case invalidAge, unsupportedAge }
        enum Node: Equatable {
            case leaf(Int)
            case word(String)
        }
        struct Age: Equatable { let value: Int }

        static var leaf: Optic<Node, Node, Int, Int>.Prism {
            Optic<Node, Node, Int, Int>.Prism(
                embed: Node.leaf, extract: { if case .leaf(let value) = $0 { value } else { nil } }
            )
        }
        static var word: Optic<Node, Node, String, String>.Prism {
            Optic<Node, Node, String, String>.Prism(
                embed: Node.word, extract: { if case .word(let value) = $0 { value } else { nil } }
            )
        }
        static func marker(_ text: String) -> Coder<Substring, Void, Substring, Failure> {
            Coder(
                parse: { input throws(Failure) in
                    guard input.hasPrefix(text) else { throw .absent }
                    input.removeFirst(text.count)
                }, serialize: { _, buffer throws(Failure) in buffer.append(contentsOf: text) })
        }
        static var integer: Coder<Substring, Int, Substring, Failure> {
            Coder<Substring, Int, Substring, Failure>(
                parse: { input throws(Failure) in
                    let digits = input.prefix { $0 >= "0" && $0 <= "9" }
                    guard !digits.isEmpty, let value = Int(digits) else { throw .malformed }
                    input.removeFirst(digits.count)
                    return value
                },
                serialize: { value, buffer throws(Failure) in
                    guard value >= 0 else { throw .malformed }
                    buffer.append(contentsOf: String(value))
                }
            )
        }
        static var letters: Coder<Substring, String, Substring, Failure> {
            Coder<Substring, String, Substring, Failure>(
                parse: { input throws(Failure) in
                    let token = input.prefix(while: \.isLetter)
                    guard !token.isEmpty else { throw .malformed }
                    input.removeFirst(token.count)
                    return String(token)
                },
                serialize: { value, buffer throws(Failure) in
                    guard !value.isEmpty, value.allSatisfy(\.isLetter) else { throw .malformed }
                    buffer.append(contentsOf: value)
                }
            )
        }
        static var grammar: some Coding<Substring, Node, Substring, Failure> {
            return Coder::OneOf.Sequence(absent: Failure.absent) {
                Coder::Case(leaf, absent: Failure.absent) {
                    marker("@")
                    marker("leaf:")
                    integer
                }
                Coder::Case(word, absent: Failure.absent) {
                    marker("@")
                    marker("word:")
                    letters
                }
            }
        }

        @Test func explicitTagsAndCanonicalPrinting() throws {
            var input: Substring = "@leaf:007!"
            #expect(try Self.grammar.parse(&input) == .leaf(7))
            #expect(input == "!")
            var output: Substring = ""
            try Self.grammar.serialize(.leaf(7), into: &output)
            #expect(output == "@leaf:7")
        }
        @Test func retriesAfterPartialRejectedTag() throws {
            var input: Substring = "@word:Élodie!"
            #expect(try Self.grammar.parse(&input) == .word("Élodie"))
            #expect(input == "!")
            var output: Substring = "prefix:"
            try Self.grammar.serialize(.word("Élodie"), into: &output)
            #expect(output == "prefix:@word:Élodie")
        }
        @Test func recognizedMalformedBranchIsFatal() {
            var input: Substring = "@leaf:bad"
            #expect(throws: Failure.malformed) { try Self.grammar.parse(&input) }
            #expect(input == "bad")
        }
        @Test func finalRejectionRestoresWholeAlternative() {
            var input: Substring = "@unknown:3"
            #expect(throws: Failure.absent) { try Self.grammar.parse(&input) }
            #expect(input == "@unknown:3")
        }
        @Test func wrongCaseRejectsBeforeWriting() {
            let leaf = Coder::Case(Self.leaf, absent: Failure.absent) { Self.integer }
            var buffer: Substring = "prefix:"
            #expect(throws: Failure.absent) { try leaf.serialize(.word("name"), into: &buffer) }
            #expect(buffer == "prefix:")
        }
        @Test func fatalPrintingIsNotRetriedOrSilentlyDiscarded() {
            var buffer: Substring = ""
            #expect(throws: Failure.malformed) { try Self.grammar.serialize(.leaf(-1), into: &buffer) }
            #expect(buffer == "@leaf:")
        }
        @Test func allRejectedPrintingRestoresEvenWhenArmsWrote() {
            let rejecting = Coder<Substring, Int, Substring, Failure>(
                parse: { input throws(Failure) in
                    input.removeFirst()
                    throw .absent
                },
                serialize: { _, buffer throws(Failure) in
                    buffer.append("x")
                    throw .absent
                }
            )
            let choice = Coder::OneOf.Sequence(absent: Failure.absent) {
                rejecting
                rejecting
            }
            var buffer: Substring = "prefix:"
            #expect(throws: Failure.absent) { try choice.serialize(1, into: &buffer) }
            #expect(buffer == "prefix:")
        }

        static var partial: Optic<Int, Int, Age, Age>.Isomorphism.Partial<Conversion, Conversion> {
            Optic<Int, Int, Age, Age>.Isomorphism.Partial<Conversion, Conversion>(
                forward: { value throws(Conversion) in
                    guard (0...130).contains(value) else { throw .invalidAge }
                    guard value <= 99 else { throw .unsupportedAge }
                    return Age(value: value)
                },
                backward: { value throws(Conversion) in
                    guard (0...99).contains(value.value) else { throw .unsupportedAge }
                    return value.value
                }
            )
        }
        @Test func partialLawsOnSupportedSubset() throws {
            let coder = Self.integer.map(
                Self.partial, forwardFailure: Failure.conversion, backwardFailure: Failure.conversion)
            for value in 0...99 {
                let age = try Self.partial.forward(value)
                #expect(try Self.partial.backward(age) == value)
                #expect(try Self.partial.forward(Self.partial.backward(age)) == age)
                var output: Substring = ""
                try coder.serialize(age, into: &output)
                #expect(try coder.parse(&output) == age)
                #expect(output.isEmpty)
            }
            var source: Substring = "131!"
            #expect(throws: Failure.conversion(.invalidAge)) { try coder.parse(&source) }
            #expect(source == "!")
            var output: Substring = "prefix:"
            #expect(throws: Failure.conversion(.unsupportedAge)) {
                try coder.serialize(Age(value: 130), into: &output)
            }
            #expect(output == "prefix:")
        }
        @Test func adapterNormalizationDoesNotPromiseExactSpelling() throws {
            let adapter = Optic<Int, Int, Age, Age>.Adapter<Never, Never>(
                forward: { Age(value: $0) }, backward: { $0.value }
            )
            let coder = Self.integer.map(adapter, forwardFailure: { $0 }, backwardFailure: { $0 })
            var source: Substring = "007"
            let age = try coder.parse(&source)
            var output: Substring = ""
            try coder.serialize(age, into: &output)
            #expect(output == "7")
        }
    }
#endif
