public import Parser
public import Serializer

extension Coder {

    @resultBuilder
    public struct Builder<Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable> {}
}

extension Coder.Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {

    @inlinable
    public static func buildExpression<C: Coder.`Protocol`>(
        _ coder: C
    ) -> C
    where
        C.Input == Input,
        C.Buffer == Buffer,
        C.Input: ~Copyable & ~Escapable,
        C.Output: ~Copyable & ~Escapable,
        C.Buffer: ~Copyable & ~Escapable
    {
        coder
    }

    @inlinable
    public static func buildBlock<C: Coder.`Protocol`>(
        _ coder: C
    ) -> C
    where
        C.Input == Input,
        C.Buffer == Buffer,
        C.Input: ~Copyable & ~Escapable,
        C.Output: ~Copyable & ~Escapable,
        C.Buffer: ~Copyable & ~Escapable
    {
        coder
    }

    @inlinable
    public static func buildPartialBlock<C: Coder.`Protocol`>(
        first: C
    ) -> C
    where
        C.Input == Input,
        C.Buffer == Buffer,
        C.Input: ~Copyable & ~Escapable,
        C.Output: ~Copyable & ~Escapable,
        C.Buffer: ~Copyable & ~Escapable
    {
        first
    }
}
