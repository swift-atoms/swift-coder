public import Coder
public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Parser
import Serializer

extension Coder.Element {

    public struct Exact<
        Input: Cursor.`Protocol` & ~Copyable,
        Sink: RangeReplaceableCollection
    >
    where Input.Element: Equatable & Copyable & Escapable, Input.Failure == Never, Sink.Element == Input.Element {

        public let underlying: Input.Element

        public init(_ underlying: Input.Element) {
            self.underlying = underlying
        }
    }
}

extension Coder.Element.Exact {

    public enum Error: Swift.Error, Equatable {

        case missing(expected: Input.Element)

        case mismatch(expected: Input.Element, found: Input.Element)
    }
}

extension Coder.Element.Exact: Coder.`Protocol` {

    public typealias Output = Swift.Void

    public typealias Failure = Error

    public typealias Buffer = Sink

    public typealias Body = Swift.Never

    @inlinable
    public var body: Swift.Never {
        borrowing get {
            return fatalError("leaf coder — parse(_:) and serialize(_:into:) are implemented directly")
        }
    }

    @inlinable
    public func parse(_ input: inout Input) throws(Error) {
        let checkpoint = input.checkpoint
        guard let found = input.next() else {
            throw .missing(expected: underlying)
        }
        guard found == underlying else {
            input.seek(to: checkpoint)
            throw .mismatch(expected: underlying, found: found)
        }
    }

    @inlinable
    public borrowing func serialize(_ output: Swift.Void, into buffer: inout Sink) {
        buffer.append(underlying)
    }
}
