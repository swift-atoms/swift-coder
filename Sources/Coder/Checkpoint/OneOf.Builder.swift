#if Checkpoint
    public import Checkpoint
    public import Parser
    public import Serializer

    extension OneOf {

        @resultBuilder
        public struct Builder<
            Input: Restorable & ~Copyable & ~Escapable,
            Output: ~Copyable & Escapable,
            Buffer: Restorable & ~Copyable & ~Escapable,
            Failure: Swift.Error & Equatable
        > {}
    }

    extension OneOf.Builder
    where
        Input: Restorable & ~Copyable & ~Escapable,
        Output: ~Copyable & Escapable,
        Buffer: Restorable & ~Copyable & ~Escapable
    {

        @inlinable
        public static func buildExpression<C: Coding>(
            _ coder: C
        ) -> C
        where
            C.Input == Input,
            C.Output == Output,
            C.Buffer == Buffer,
            C.Failure == Failure,
            C.Input: ~Copyable & ~Escapable,
            C.Output: ~Copyable & Escapable,
            C.Buffer: ~Copyable & ~Escapable
        {
            coder
        }

        @inlinable
        public static func buildPartialBlock<C: Coding>(
            first: C
        ) -> OneOf.Deferred<C>
        where
            C.Input == Input,
            C.Output == Output,
            C.Buffer == Buffer,
            C.Failure == Failure,
            C.Input: ~Copyable & ~Escapable,
            C.Output: ~Copyable & Escapable,
            C.Buffer: ~Copyable & ~Escapable
        {
            .init { _ in first }
        }

        @inlinable
        public static func buildPartialBlock<Accumulated: Coding, Next: Coding>(
            accumulated: OneOf.Deferred<Accumulated>,
            next: Next
        ) -> OneOf.Deferred<OneOf.Two<Accumulated, Next>>
        where
            Accumulated.Input == Input,
            Accumulated.Output == Output,
            Accumulated.Buffer == Buffer,
            Accumulated.Failure == Failure,
            Next.Input == Input,
            Next.Output == Output,
            Next.Buffer == Buffer,
            Next.Failure == Failure,
            Accumulated.Input: ~Copyable & ~Escapable,
            Accumulated.Output: ~Copyable & Escapable,
            Accumulated.Buffer: ~Copyable & ~Escapable,
            Next.Input: ~Copyable & ~Escapable,
            Next.Output: ~Copyable & Escapable,
            Next.Buffer: ~Copyable & ~Escapable
        {
            .init { absent in OneOf.Two(accumulated(absent: absent), next, absent: absent) }
        }
    }

#endif
