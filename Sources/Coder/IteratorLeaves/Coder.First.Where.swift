#if IteratorLeaves
public import Either
public import Iterator
public import Parser
import Serializer

extension Coder::First {

    public struct Where<
        Input: Iterator.`Protocol` & ~Copyable & ~Escapable,
        Buffer: RangeReplaceableCollection
    >: Coding
    where Input.Element: Copyable & Escapable, Input.Failure == Never, Buffer.Element == Input.Element {


        public typealias Output = Input.Element

        public typealias Failure = Either<Parser::EndOfInput.Error, Parser::First.Where<Input>.Error>


        @usableFromInline
        let predicate: (Input.Element) -> Bool

        @usableFromInline
        let expected: String

        @inlinable
        public init(
            expected: String = "matching element",
            _ predicate: @escaping (Input.Element) -> Bool
        ) {
            self.predicate = predicate
            self.expected = expected
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Input.Element {
            try Parser::First.Where<Input>(expected: expected, predicate).parse(&input)
        }

        @inlinable
        public borrowing func serialize(_ output: Input.Element, into buffer: inout Buffer) throws(Failure) {
            guard predicate(output) else {
                throw .right(.predicateFailed(expected: expected))
            }
            buffer.append(output)
        }
    }
}
#endif
