public import Either
public import Parser
public import Serializer

extension Coder.Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Coder.`Protocol`, N: Coder.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Parser.Append<A, N, Either<A.Failure, N.Failure>, repeat each O>
    where
        A.Input == Input,
        N.Input == Input,
        A.Buffer == Buffer,
        N.Buffer == Buffer,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Buffer: ~Copyable & ~Escapable,
        N.Buffer: ~Copyable & ~Escapable,
        A.Output == (repeat each O)
    {
        Parser.Append(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Coder.`Protocol`, N: Coder.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Parser.Append<A, N, A.Failure, repeat each O>
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
        A.Failure == N.Failure
    {
        Parser.Append(accumulated, next, { $0 }, { $0 })
    }
}
