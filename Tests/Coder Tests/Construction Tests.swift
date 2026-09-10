#if Either
    import Coder
    import Testing

    private enum ChosenFailure: Error, Equatable { case mismatch }
    private struct Chosen: Coding {
        let character: Character
        func parse(_ input: inout Substring) throws(ChosenFailure) -> Character {
            guard input.first == character else { throw .mismatch }
            input.removeFirst()
            return character
        }
        func serialize(_ output: Character, into buffer: inout String) throws(ChosenFailure) {
            guard output == character else { throw .mismatch }
            buffer.append(output)
        }
    }
    private struct ConditionalBranch: Coding {
        let first: Bool
        @Coder::Builder<Substring, String>
        var body: some Coding<Substring, Character, String, Either<ChosenFailure, ChosenFailure>> {
            if first { Chosen(character: "a") } else { Chosen(character: "b") }
        }
    }
    @Suite struct ConstructionTests {
        @Test func selectedBranchIsFixedAtConstruction() throws {
            let coder = ConditionalBranch(first: false)
            var input: Substring = "b!"
            #expect(try coder.parse(&input) == "b")
            #expect(input == "!")
            var buffer = ""
            try coder.serialize("b", into: &buffer)
            #expect(buffer == "b")
            var wrong: Substring = "a"
            #expect(throws: Either<ChosenFailure, ChosenFailure>.right(.mismatch)) { try coder.parse(&wrong) }
            #expect(wrong == "a")
        }
    }
#endif
