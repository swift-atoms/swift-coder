#if Skip
    public import Skip
    public import Either
    extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<A.Output, Void>.Coder<A, N, Either<A.Failure, N.Failure>>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, N.Output == Void
        {
            .init(accumulated, next, leading: false, { .left($0) }, { .right($0) })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<A.Output, Void>.Coder<A, N, A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, N.Output == Void,
            A.Failure == N.Failure
        {
            .init(accumulated, next, leading: false, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<N.Output, Void>.Coder<N, A, Either<A.Failure, N.Failure>>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void
        {
            .init(next, accumulated, leading: true, { .right($0) }, { .left($0) })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<N.Output, Void>.Coder<N, A, A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            A.Failure == N.Failure
        {
            .init(next, accumulated, leading: true, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<Void, Void>.Coder<A, N, Either<A.Failure, N.Failure>>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            N.Output == Void
        {
            .init(accumulated, next, { .left($0) }, { .right($0) })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<Void, Void>.Coder<A, N, A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            N.Output == Void, A.Failure == N.Failure
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
    }
#endif
