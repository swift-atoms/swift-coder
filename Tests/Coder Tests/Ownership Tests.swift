import Coder
import Testing

private struct LinearValue: ~Copyable { let value: UInt8 }
private final class Destructions { var count = 0 }
private struct Resource: ~Copyable {
    let counter: Destructions
    deinit { counter.count += 1 }
}
private struct LinearCoder: Coding, ~Copyable {
    let resource: Resource
    borrowing func parse(_ input: inout ArraySlice<UInt8>) -> LinearValue {
        LinearValue(value: input.removeFirst())
    }
    borrowing func serialize(_ output: borrowing LinearValue, into buffer: inout [UInt8]) {
        buffer.append(output.value)
    }
}

@Suite struct OwnershipTests {
    @Test func directCoderBorrowsNoncopyableOutput() {
        let coder = Coder<ArraySlice<UInt8>, LinearValue, [UInt8], Never>(
            parse: { input in LinearValue(value: input.removeFirst()) },
            serialize: { value, output in output.append(value.value) }
        )
        var input: ArraySlice<UInt8> = [7]
        let value = coder.parse(&input)
        var buffer: [UInt8] = []
        coder.serialize(value, into: &buffer)
        coder.serialize(value, into: &buffer)
        #expect(buffer == [7, 7])
    }

    @Test func directCoderSupportsScopedInputAndOutput() {
        let coder = Coder<Span<UInt8>, Span<UInt8>, [UInt8], Never>(
            parse: { input in input },
            serialize: { value, output in
                for byte in value { output.append(byte) }
            }
        )
        let storage: [UInt8] = [1, 2, 3]
        var input = storage.span
        let span = coder.parse(&input)
        var buffer: [UInt8] = []
        coder.serialize(span, into: &buffer)
        #expect(buffer == storage)
    }

    #if Pair
        @Test func pairRetainsNoncopyableComponentsAndBorrowsBothFields() {
            let counter = Destructions()
            func scope() {
                let coder = Pair(
                    LinearCoder(resource: Resource(counter: counter)),
                    LinearCoder(resource: Resource(counter: counter))
                ).coder()
                var input: ArraySlice<UInt8> = [4, 8]
                let values = coder.parse(&input)
                var output: [UInt8] = []
                coder.serialize(values, into: &output)
                coder.serialize(values, into: &output)
                #expect(output == [4, 8, 4, 8])
                #expect(counter.count == 0)
            }
            scope()
            #expect(counter.count == 2)
        }
    #endif

    #if Map
        @Test func conversionAndFailureMappingRetainSingleOwnedComponent() {
            enum Failure: Error { case unused }
            let counter = Destructions()
            func scope() {
                let mapped = LinearCoder(resource: Resource(counter: counter))
                    .map(to: { $0.value }, from: { LinearValue(value: $0) })
                    .mapFailure { (never: Never) -> Failure in never }
                var input: ArraySlice<UInt8> = [9]
                let value = try! mapped.parse(&input)
                var output: [UInt8] = []
                try! mapped.serialize(value, into: &output)
                #expect(output == [9])
                #expect(counter.count == 0)
            }
            scope()
            #expect(counter.count == 1)
        }
    #endif
}

#if Repetition
    private struct LinearByteCoder: Coding, ~Copyable {
        enum Failure: Error { case absent, invalid }
        let resource: Resource
        borrowing func parse(_ input: inout ArraySlice<UInt8>) throws(Failure) -> UInt8 {
            guard !input.isEmpty else { throw .absent }
            return input.removeFirst()
        }
        borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) throws(Failure) {
            buffer.append(output)
        }
    }
    extension OwnershipTests {
        @Test func repetitionRetainsNoncopyableOperation() throws {
            let counter = Destructions()
            func scope() throws {
                let coder = Repetition(
                    (0...), operation: LinearByteCoder(resource: Resource(counter: counter))
                )
                .coder(rejected: { if case .absent = $0 { true } else { false } }, failure: { _ in .invalid })
                var input: ArraySlice<UInt8> = [1, 2]
                let values = try coder.parse(&input)
                var output: [UInt8] = []
                try coder.serialize(values, into: &output)
                #expect(output == [1, 2])
                #expect(counter.count == 0)
            }
            try scope()
            #expect(counter.count == 1)
        }
    }
#endif

#if Checkpoint && Optic
    private enum OwnedChoiceFailure: Error, Equatable { case absent }
    private struct OwnedChoice: Coding, ~Copyable {
        let resource: Resource
        let byte: UInt8
        borrowing func parse(_ input: inout Substring) throws(OwnedChoiceFailure) -> UInt8 {
            guard let first = input.first else { throw .absent }
            input.removeFirst()
            guard first.wholeNumberValue == Int(byte) else { throw .absent }
            return byte
        }
        borrowing func serialize(_ output: UInt8, into buffer: inout Substring) throws(OwnedChoiceFailure) {
            buffer.append(contentsOf: String(output))
            guard output == byte else { throw .absent }
        }
    }
    private enum LinearCase: ~Copyable {
        case leaf(UInt8)
        case empty
    }
    extension OwnershipTests {
        @Test func directAlternativeRetainsTwoNoncopyableBranches() throws {
            let counter = Destructions()
            func scope() throws {
                let choice = Coder::OneOf.Two(
                    OwnedChoice(resource: Resource(counter: counter), byte: 1),
                    OwnedChoice(resource: Resource(counter: counter), byte: 2), absent: .absent
                )
                var input: Substring = "2tail"
                #expect(try choice.parse(&input) == 2)
                #expect(input == "tail")
                var output: Substring = "prefix:"
                try choice.serialize(2, into: &output)
                #expect(output == "prefix:2")
                #expect(counter.count == 0)
            }
            try scope()
            #expect(counter.count == 2)
        }
        @Test func caseBorrowsItsNoncopyableContentAndSource() throws {
            let counter = Destructions()
            func scope() throws {
                let prism = Optic<LinearCase, LinearCase, UInt8, UInt8>.Prism(
                    match: { source in
                        switch consume source {
                        case .leaf(let byte): .right(byte)
                        case .empty: .left(.empty)
                        }
                    }, embed: LinearCase.leaf
                )
                let fold = Optic<LinearCase, LinearCase, UInt8, UInt8>.Fold { source, visit in
                    switch source {
                    case .leaf(let value):
                        visit(value)
                        return true
                    case .empty: return false
                    }
                }
                let coder = Coder::Case(prism, fold, absent: OwnedChoiceFailure.absent) {
                    OwnedChoice(resource: Resource(counter: counter), byte: 2)
                }
                let source = LinearCase.leaf(2)
                var output: Substring = ""
                try coder.serialize(source, into: &output)
                try coder.serialize(source, into: &output)
                #expect(output == "22")
                #expect(counter.count == 0)
            }
            try scope()
            #expect(counter.count == 1)
        }
    }
#endif
