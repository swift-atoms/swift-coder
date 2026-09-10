#if Skip
    public import Skip
    extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<A.Output, Void>.Coder<A, N, N.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, N.Output == Void,
            A.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<A.Output, Void>.Coder<A, N, A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, N.Output == Void,
            N.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<A.Output, Void>.Coder<A, N, Never>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, N.Output == Void,
            A.Failure == Never, N.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<N.Output, Void>.Coder<N, A, N.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            A.Failure == Never
        {
            .init(next, accumulated, leading: true, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<N.Output, Void>.Coder<N, A, A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            N.Failure == Never
        {
            .init(next, accumulated, leading: true, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<N.Output, Void>.Coder<N, A, Never>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            A.Failure == Never, N.Failure == Never
        {
            .init(next, accumulated, leading: true, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<Void, Void>.Coder<A, N, N.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            N.Output == Void, A.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<Void, Void>.Coder<A, N, A.Failure>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            N.Output == Void, N.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
        @inlinable public static func buildPartialBlock<A: Coding & ~Copyable, N: Coding & ~Copyable>(
            accumulated: consuming A, next: consuming N
        ) -> Skip<Void, Void>.Coder<A, N, Never>
        where
            A.Input == Input, N.Input == Input, A.Buffer == Buffer, N.Buffer == Buffer,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable, A.Output == Void,
            N.Output == Void, A.Failure == Never, N.Failure == Never
        {
            .init(accumulated, next, { $0 }, { $0 })
        }
    }
#endif
