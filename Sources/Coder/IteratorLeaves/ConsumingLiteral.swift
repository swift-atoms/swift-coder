#if IteratorLeaves
public import Iterator
public import Parser
public import Serializer

public struct ConsumingLiteral<Input: Iterator.`Protocol` & ~Copyable & ~Escapable,
                               OutputBuffer: RangeReplaceableCollection>: Coding
where Input.Element: Equatable & Copyable & Escapable,
      Input.Failure == Never, OutputBuffer.Element == Input.Element {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf coder: implement parse and serialize directly")
        }
    }

    public typealias Buffer = OutputBuffer
        public typealias Output = Void
    public typealias Failure = Parser::ConsumingLiteral<Input>.Error
    public let elements: [Input.Element]
    @inlinable public init(_ elements: [Input.Element]) { self.elements = elements }
    @inlinable public borrowing func parse(_ input: inout Input) throws(Failure) {
        try Parser::ConsumingLiteral<Input>(elements).parse(&input)
    }
    @inlinable public borrowing func serialize(_ output: Void, into buffer: inout OutputBuffer) {
        buffer.append(contentsOf: elements)
    }
}
#endif
