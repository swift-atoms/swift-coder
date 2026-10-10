@resultBuilder
public struct Builder<Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable> {}

extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
    @inlinable public static func buildExpression<C: Coding & ~Copyable>(_ coder: consuming C) -> C
    where
        C.Input == Input, C.Buffer == Buffer, C.Input: ~Copyable & ~Escapable,
        C.Output: ~Copyable & ~Escapable, C.Buffer: ~Copyable & ~Escapable
    { coder }
    @inlinable public static func buildBlock<C: Coding & ~Copyable>(_ coder: consuming C) -> C
    where
        C.Input == Input, C.Buffer == Buffer, C.Input: ~Copyable & ~Escapable,
        C.Output: ~Copyable & ~Escapable, C.Buffer: ~Copyable & ~Escapable
    { coder }
    @inlinable public static func buildPartialBlock<C: Coding & ~Copyable>(first: consuming C) -> C
    where
        C.Input == Input, C.Buffer == Buffer, C.Input: ~Copyable & ~Escapable,
        C.Output: ~Copyable & ~Escapable, C.Buffer: ~Copyable & ~Escapable
    { first }
}
