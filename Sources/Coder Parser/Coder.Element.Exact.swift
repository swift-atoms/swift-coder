public import Coder
public import Input
public import Parser
import Serializer_Core

extension Coder.Element {

    public struct Exact<
        Input: Input.Input.`Protocol` & ~Copyable,
        Sink: RangeReplaceableCollection
    >
    where Input.Element: Equatable, Sink.Element == Input.Element {

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
        let found: Input.Element
        do throws(Input.Input.Stream.Error) {
            found = try input.advance()
        } catch {
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
