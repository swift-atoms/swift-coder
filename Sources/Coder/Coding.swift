public import Parser
public import Serializer

/// A composition that retains parsing and borrowed serialization.
public protocol Coding<Input, Output, Buffer, Failure>: Parsing, Serializing, ~Copyable
where Input: ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
    @Builder<Input, Buffer>
    var body: Body { borrowing get }
}

extension Coding
where
    Self: ~Copyable, Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable, Body == Never
{
    @inlinable public var body: Never {
        borrowing get { fatalError("\(Self.self) is a leaf coder: implement parse and serialize directly") }
    }
}
