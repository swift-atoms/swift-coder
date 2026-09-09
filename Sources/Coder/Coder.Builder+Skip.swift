public import Skip_Parser
public import Either
public import Parser
public import Serializer

extension Coder.Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Coder.`Protocol`, N: Coder.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Skip::Skip<A.Output, N.Output>.Parser<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Buffer == Buffer,
        N.Buffer == Buffer,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Buffer: ~Copyable & ~Escapable,
        N.Buffer: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        N.Output == Void
    {
        Skip::Skip.Parser(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Coder.`Protocol`, N: Coder.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Skip::Skip<A.Output, N.Output>.Parser<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Buffer == Buffer,
        N.Buffer == Buffer,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Buffer: ~Copyable & ~Escapable,
        N.Buffer: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        N.Output == Void,
        A.Failure == N.Failure
    {
        Skip::Skip.Parser(accumulated, next, { $0 }, { $0 })
    }
}
