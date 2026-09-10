#if Map
    public import Map

    extension Coding
    where
        Self: ~Copyable, Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable,
        Buffer: ~Copyable & ~Escapable
    {
        @inlinable public consuming func map<New: ~Copyable>(
            to forward: @escaping (consuming Output) -> New,
            from backward: @escaping (borrowing New) -> Output
        ) -> Map<Output, New, Failure>.Coder<Self> {
            .init(
                upstream: self,
                forward: { value throws(Failure) in forward(value) },
                backward: { value throws(Failure) in backward(value) })
        }

        /// Both arrows are retained. A one-way Parsing.map remains parse-only.
        @_disfavoredOverload
        @inlinable public consuming func map<New: ~Copyable>(
            to forward: @escaping (consuming Output) throws(Failure) -> New,
            from backward: @escaping (borrowing New) throws(Failure) -> Output
        ) -> Map<Output, New, Failure>.Coder<Self> {
            .init(upstream: self, forward: forward, backward: backward)
        }

        /// Maps the same shared failure in both directions, retaining ownership.
        @inlinable public consuming func mapFailure<E: Swift.Error>(_ transform: @escaping (Failure) -> E)
            -> Map<Failure, E, Never>.Error.Coder<Self>
        {
            .init(self, transform)
        }
    }
#endif
