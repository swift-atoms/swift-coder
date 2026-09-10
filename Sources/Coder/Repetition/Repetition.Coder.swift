#if Repetition
    public import Repetition
    public import Cardinal
    public import Checkpoint

    extension Repetition
    where
        Bounds: Cardinal.Range, Operation: Coding & ~Copyable,
        Operation.Input: Restorable & ~Copyable & ~Escapable, Operation.Input.Checkpoint: Equatable,
        Operation.Output: Copyable & Escapable, Operation.Buffer: ~Copyable & ~Escapable
    {
        /// Repeats complete elements, restoring a rejected separator+element attempt.
        /// Fatal failures preserve the cursor and buffer at the point of failure.
        public struct Coder<Separator: Coding & ~Copyable>: Coding, ~Copyable
        where
            Separator.Input == Operation.Input, Separator.Output == Void,
            Separator.Buffer == Operation.Buffer, Separator.Failure == Operation.Failure,
            Separator.Input: ~Copyable & ~Escapable, Separator.Buffer: ~Copyable & ~Escapable
        {
            public typealias Input = Operation.Input
            public typealias Output = [Operation.Output]
            public typealias Buffer = Operation.Buffer
            public typealias Failure = Operation.Failure
            public let wrapped: Repetition<Bounds, Operation>
            public let separator: Separator?
            public let rejected: (Failure) -> Bool
            public let failure: (Repetition<Bounds, Operation>.Error) -> Failure

            public init(
                _ wrapped: consuming Repetition<Bounds, Operation>, separator: consuming Separator?,
                rejected: @escaping (Failure) -> Bool,
                failure: @escaping (Repetition<Bounds, Operation>.Error) -> Failure
            ) {
                self.wrapped = wrapped
                self.separator = separator
                self.rejected = rejected
                self.failure = failure
            }

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                guard wrapped.bounds.contains(wrapped.bounds.minimum) else { throw failure(.emptyBounds) }
                var output: Output = []
                var count = Cardinal.zero
                while wrapped.bounds.permitsAnother(after: count) {
                    let checkpoint = input.checkpoint
                    guard count.rawValue != UInt.max else { throw failure(.countOverflow) }
                    let value: Operation.Output
                    do throws(Failure) {
                        if count != .zero {
                            switch separator {
                            case .some(let separator): try separator.parse(&input)
                            case .none: break
                            }
                        }
                        value = try wrapped.operation.parse(&input)
                    } catch {
                        guard rejected(error) else { throw error }
                        input.seek(to: checkpoint)
                        guard wrapped.bounds.contains(count) else {
                            throw failure(.insufficient(actual: count))
                        }
                        return output
                    }
                    guard input.checkpoint != checkpoint else {
                        input.seek(to: checkpoint)
                        throw failure(.noProgress)
                    }
                    output.append(value)
                    count = Cardinal(count.rawValue + 1)
                }
                return output
            }

            public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                guard wrapped.bounds.contains(wrapped.bounds.minimum) else { throw failure(.emptyBounds) }
                let count = Cardinal(UInt(output.count))
                guard wrapped.bounds.contains(count) else {
                    if count < wrapped.bounds.minimum { throw failure(.insufficient(actual: count)) }
                    throw failure(.excessive(actual: count))
                }
                for index in output.indices {
                    if index != output.startIndex {
                        switch separator {
                        case .some(let separator): try separator.serialize((), into: &buffer)
                        case .none: break
                        }
                    }
                    try wrapped.operation.serialize(output[index], into: &buffer)
                }
            }
        }

        public consuming func coder(
            rejected: @escaping (Operation.Failure) -> Bool,
            failure: @escaping (Repetition<Bounds, Operation>.Error) -> Operation.Failure
        ) -> Coder<Coder::Coder<Operation.Input, Void, Operation.Buffer, Operation.Failure>> {
            .init(self, separator: nil, rejected: rejected, failure: failure)
        }

        public consuming func coder<Separator: Coding & ~Copyable>(
            separatedBy separator: consuming Separator,
            rejected: @escaping (Operation.Failure) -> Bool,
            failure: @escaping (Repetition<Bounds, Operation>.Error) -> Operation.Failure
        ) -> Coder<Separator>
        where
            Separator.Input == Operation.Input, Separator.Output == Void,
            Separator.Buffer == Operation.Buffer, Separator.Failure == Operation.Failure,
            Separator.Input: ~Copyable & ~Escapable, Separator.Buffer: ~Copyable & ~Escapable
        {
            .init(self, separator: separator, rejected: rejected, failure: failure)
        }
    }

    extension Repetition.Coder: Copyable
    where
        Bounds: Cardinal.Range,
        Operation: Coding<Operation.Input, Operation.Output, Operation.Buffer, Operation.Failure> & Copyable,
        Operation.Input: Restorable & ~Copyable & ~Escapable, Operation.Input.Checkpoint: Equatable,
        Operation.Output: Copyable & Escapable, Operation.Buffer: ~Copyable & ~Escapable,
        Separator: Coding<Separator.Input, Separator.Output, Separator.Buffer, Separator.Failure> & Copyable,
        Separator.Input: ~Copyable & ~Escapable, Separator.Buffer: ~Copyable & ~Escapable
    {}
#endif
