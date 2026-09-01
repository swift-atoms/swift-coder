public import Coder
public import Cursor_Parser_First
public import Iterator
public import Iterator_Protocol
public import Parser
import Serializer

extension Coder.Element {

    public struct First<
        Input: Iterator.`Protocol` & ~Copyable,
        Sink: RangeReplaceableCollection
    >
    where Input.Element: Copyable & Escapable, Input.Failure == Never, Sink.Element == Input.Element {

        public init() {}
    }
}

extension Coder.Element.First: Coder.`Protocol` {

    public typealias Output = Input.Element

    public typealias Failure = Parser.EndOfInput.Error

    public typealias Buffer = Sink

    public typealias Body = Swift.Never

    @inlinable
    public var body: Swift.Never {
        borrowing get {
            return fatalError("leaf coder — parse(_:) and serialize(_:into:) are implemented directly")
        }
    }

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Input.Element {
        guard let element = input.next() else {
            throw .unexpected(expected: "any element")
        }
        return element
    }

    @inlinable
    public borrowing func serialize(_ output: Input.Element, into buffer: inout Sink) {
        buffer.append(output)
    }
}
