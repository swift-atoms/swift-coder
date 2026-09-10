#if Pair
    public import Pair
    extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Pair<A, N>.Coder<N.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Pair<A, N>.Coder<A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, N.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Pair<A, N>.Coder<Never>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Failure == Never,
            N.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
    }
#endif
