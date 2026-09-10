#if Either
    public import Either

    extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
        @inlinable
        public static func buildExpression<L: Coding & ~Copyable, R: Coding & ~Copyable>(
            _ either: consuming Either<L, R>
        ) -> Either<L, R>.Coder
        where
            L.Buffer == Buffer, R.Buffer == Buffer, L.Buffer: ~Copyable & ~Escapable,
            R.Buffer: ~Copyable & ~Escapable, L.Input == Input, R.Input == Input, L.Output == R.Output,
            L.Input: ~Copyable & ~Escapable, R.Input: ~Copyable & ~Escapable,
            L.Output: ~Copyable & ~Escapable, R.Output: ~Copyable & ~Escapable
        {
            .init(either)
        }

        @inlinable
        public static func buildEither<
            First: Coding & ~Copyable,
            Second: Coding & ~Copyable
        >(
            first: consuming First
        ) -> Either<First, Second>.Coder
        where
            First.Buffer == Buffer, Second.Buffer == Buffer,
            First.Buffer: ~Copyable & ~Escapable, Second.Buffer: ~Copyable & ~Escapable,
            First.Input == Input,
            Second.Input == Input,
            First.Input: ~Copyable & ~Escapable,
            Second.Input: ~Copyable & ~Escapable,
            First.Output == Second.Output,
            First.Output: ~Copyable & ~Escapable,
            Second.Output: ~Copyable & ~Escapable
        {
            .init(.left(first))
        }

        @inlinable
        public static func buildEither<
            First: Coding & ~Copyable,
            Second: Coding & ~Copyable
        >(
            second: consuming Second
        ) -> Either<First, Second>.Coder
        where
            First.Buffer == Buffer, Second.Buffer == Buffer,
            First.Buffer: ~Copyable & ~Escapable, Second.Buffer: ~Copyable & ~Escapable,
            First.Input == Input,
            Second.Input == Input,
            First.Input: ~Copyable & ~Escapable,
            Second.Input: ~Copyable & ~Escapable,
            First.Output == Second.Output,
            First.Output: ~Copyable & ~Escapable,
            Second.Output: ~Copyable & ~Escapable
        {
            .init(.right(second))
        }
    }

#endif
