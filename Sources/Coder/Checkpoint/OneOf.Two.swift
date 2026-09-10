#if Checkpoint
    public import Checkpoint
    public import Parser
    public import Serializer

    extension OneOf {

        public struct Two<P0: Coding & ~Copyable, P1: Coding & ~Copyable>: Coding, ~Copyable
        where
            P0.Input == P1.Input,
            P0.Output == P1.Output,
            P0.Buffer == P1.Buffer,
            P0.Failure == P1.Failure,
            P0.Input: Restorable & ~Copyable & ~Escapable,
            P1.Input: ~Copyable & ~Escapable,
            P0.Output: ~Copyable & Escapable,
            P1.Output: ~Copyable & Escapable,
            P0.Buffer: Restorable & ~Copyable & ~Escapable,
            P1.Buffer: ~Copyable & ~Escapable,
            P0.Failure: Equatable
        {

            public typealias Input = P0.Input

            public typealias Output = P0.Output

            public typealias Buffer = P0.Buffer

            public typealias Failure = P0.Failure

            public let p0: P0

            public let p1: P1

            public let absent: Failure

            @inlinable
            public init(_ p0: consuming P0, _ p1: consuming P1, absent: Failure) {
                self.p0 = p0
                self.p1 = p1
                self.absent = absent
            }

            @inlinable
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let checkpoint = input.checkpoint
                do throws(Failure) {
                    return try p0.parse(&input)
                } catch {
                    guard error == absent else { throw error }
                    input.seek(to: checkpoint)
                    do throws(Failure) { return try p1.parse(&input) } catch {
                        if error == absent { input.seek(to: checkpoint) }
                        throw error
                    }
                }
            }

            @inlinable
            public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                let checkpoint = buffer.checkpoint
                do throws(Failure) {
                    try p0.serialize(output, into: &buffer)
                } catch {
                    guard error == absent else { throw error }
                    buffer.seek(to: checkpoint)
                    do throws(Failure) { try p1.serialize(output, into: &buffer) } catch {
                        if error == absent { buffer.seek(to: checkpoint) }
                        throw error
                    }
                }
            }
        }
    }

    extension OneOf.Two: Copyable
    where
        P0: Coding<P0.Input, P0.Output, P0.Buffer, P0.Failure> & Copyable,
        P1: Coding<P1.Input, P1.Output, P1.Buffer, P1.Failure> & Copyable,
        P0.Input: Restorable & ~Copyable & ~Escapable, P1.Input: ~Copyable & ~Escapable,
        P0.Output: ~Copyable & Escapable, P1.Output: ~Copyable & Escapable,
        P0.Buffer: Restorable & ~Copyable & ~Escapable, P1.Buffer: ~Copyable & ~Escapable
    {}
#endif
