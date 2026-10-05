#if IteratorLeaves
public import Iterator
public import Parser
import Serializer

extension Coder::First {

    public struct Element<
        Input: Iterator.`Protocol` & ~Copyable & ~Escapable,
        OutputBuffer: RangeReplaceableCollection
    >: Coding
    where Input.Element: Copyable & Escapable, Input.Failure == Never, OutputBuffer.Element == Input.Element {
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf coder: implement parse and serialize directly")
            }
        }


        public typealias Buffer = OutputBuffer
        public typealias Output = Input.Element

        public typealias Failure = Parser::EndOfInput.Error


        @inlinable
        public init() {}

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Input.Element {
            try Parser::First.Element<Input>().parse(&input)
        }

        @inlinable
        public borrowing func serialize(_ output: Input.Element, into buffer: inout OutputBuffer) {
            buffer.append(output)
        }
    }
}
#endif
