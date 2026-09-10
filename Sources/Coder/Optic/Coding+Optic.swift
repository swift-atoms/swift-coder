#if Optic
    public import Optic
    public import Map

    extension Coding
    where
        Self: ~Copyable, Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable,
        Buffer: ~Copyable & ~Escapable
    {
        /// A consuming optic backward arrow requires a copyable new domain value.
        /// Use map(to:from:) with a borrowed projection for noncopyable values.
        @inlinable public consuming func map<Focus>(
            _ isomorphism: Optic<Output, Output, Focus, Focus>.Isomorphism
        ) -> Map<Output, Focus, Failure>.Coder<Self> {
            map(to: { isomorphism.forward($0) }, from: { isomorphism.backward(copy $0) })
        }

        /// Explicitly maps forward and backward conversion failures into the shared
        /// grammar failure. An Adapter may normalize; it need not obey inverse laws.
        @inlinable
        public consuming func map<Focus, ForwardFailure: Swift.Error, BackwardFailure: Swift.Error>(
            _ adapter: Optic<Output, Output, Focus, Focus>.Adapter<ForwardFailure, BackwardFailure>,
            forwardFailure: @escaping (ForwardFailure) -> Failure,
            backwardFailure: @escaping (BackwardFailure) -> Failure
        ) -> Map<Output, Focus, Failure>.Coder<Self> {
            map(
                to: { value throws(Failure) in
                    do throws(ForwardFailure) { return try adapter.forward(value) } catch {
                        throw forwardFailure(error)
                    }
                },
                from: { value throws(Failure) in
                    do throws(BackwardFailure) { return try adapter.backward(copy value) } catch {
                        throw backwardFailure(error)
                    }
                })
        }

        @inlinable
        public consuming func map<Focus, ForwardFailure: Swift.Error, BackwardFailure: Swift.Error>(
            _ partial: Optic<Output, Output, Focus, Focus>.Isomorphism.Partial<
                ForwardFailure, BackwardFailure
            >,
            forwardFailure: @escaping (ForwardFailure) -> Failure,
            backwardFailure: @escaping (BackwardFailure) -> Failure
        ) -> Map<Output, Focus, Failure>.Coder<Self> {
            map(partial.adapter, forwardFailure: forwardFailure, backwardFailure: backwardFailure)
        }
    }
#endif
