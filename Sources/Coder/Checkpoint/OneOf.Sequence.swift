#if Checkpoint
    public import Checkpoint
    public import Parser
    public import Serializer

    extension OneOf {

        public struct Sequence<
            Input: Restorable & ~Copyable & ~Escapable,
            Output: ~Copyable & Escapable,
            Buffer: Restorable & ~Copyable & ~Escapable,
            Failure: Swift.Error & Equatable,
            Body: Coding
        >: Coding
        where
            Body.Input == Input,
            Body.Output == Output,
            Body.Buffer == Buffer,
            Body.Failure == Failure
        {

            public let body: Body

            public let absent: Failure

            @inlinable
            public init(
                absent: Failure,
                @OneOf.Builder<Input, Output, Buffer, Failure> _ build: () -> OneOf.Deferred<Body>
            ) {
                self.absent = absent
                self.body = build()(absent: absent)
            }

            @inlinable
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let checkpoint = input.checkpoint
                do throws(Failure) { return try body.parse(&input) } catch {
                    if error == absent { input.seek(to: checkpoint) }
                    throw error
                }
            }

            @inlinable
            public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                let checkpoint = buffer.checkpoint
                do throws(Failure) { try body.serialize(output, into: &buffer) } catch {
                    if error == absent { buffer.seek(to: checkpoint) }
                    throw error
                }
            }
        }
    }

#endif
