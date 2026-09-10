#if Pair && Skip && Always
    import Coder
    import Testing

    private enum PrecisionFailure: Error, Equatable { case mismatch }
    private struct FallibleValue: Coding {
        func parse(_ input: inout Substring) throws(PrecisionFailure) -> Int { 7 }
        func serialize(_ output: Int, into buffer: inout String) throws(PrecisionFailure) {
            guard output == 7 else { throw .mismatch }
            buffer += "7"
        }
    }
    private struct InfallibleValue: Coding {
        func parse(_ input: inout Substring) -> Int { 1 }
        func serialize(_ output: Int, into buffer: inout String) { buffer += String(output) }
    }
    private struct FallibleMarker: Coding {
        func parse(_ input: inout Substring) throws(PrecisionFailure) {}
        func serialize(_ output: Void, into buffer: inout String) throws(PrecisionFailure) {}
    }
    @Suite struct FailurePrecisionTests {
        @Test func mixedNeverPairsKeepOnlyThePossibleFailure() throws {
            let first = Coder {
                InfallibleValue()
                FallibleValue()
            }
            let second = Coder {
                FallibleValue()
                InfallibleValue()
            }
            requireFailure(first)
            requireFailure(second)
            requireFailure(Pair(InfallibleValue(), FallibleValue()).coder())
            requireFailure(Pair(FallibleValue(), InfallibleValue()).coder())
            var buffer = ""
            try first.serialize(Pair(1, 7), into: &buffer)
            #expect(buffer == "17")
        }
        @Test func unitAndFallibleValueKeepExactFailure() {
            requireFailure(
                Coder(Substring.self, String.self) {
                    Always(())
                    FallibleValue()
                    Always(())
                })
            requireFailure(
                Coder(Substring.self, String.self) {
                    Always(())
                    FallibleMarker()
                })
            requireFailure(
                Coder(Substring.self, String.self) {
                    FallibleMarker()
                    Always(())
                })
        }
        @Test func allInfallibleCompositionRemainsNonthrowing() {
            let pair = Coder {
                InfallibleValue()
                InfallibleValue()
            }
            let units = Coder(Substring.self, String.self) {
                Always(())
                InfallibleValue()
                Always(())
            }
            var input: Substring = ""
            let result = pair.parse(&input)
            var output = ""
            units.serialize(1, into: &output)
            #expect(result.first == 1 && result.second == 1)
            #expect(output == "1")
        }
        private func requireFailure<C: Coding>(_ coder: C)
        where
            C.Failure == PrecisionFailure,
            C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable & ~Escapable,
            C.Buffer: ~Copyable & ~Escapable
        {}
    }
#endif
