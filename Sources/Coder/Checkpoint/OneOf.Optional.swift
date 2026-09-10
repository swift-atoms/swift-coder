#if Checkpoint
    public import Checkpoint

    extension OneOf {
        /// Input-driven optional value. A present value must serialize successfully.
        /// Swift.Optional<Content>.Coder instead models optional grammar construction.
        public struct Optional<Content: Coding & ~Copyable>: Coding, ~Copyable
        where
            Content.Input: Restorable & ~Copyable & ~Escapable,
            Content.Output: ~Copyable & Escapable, Content.Buffer: ~Copyable & ~Escapable
        {
            public typealias Input = Content.Input
            public typealias Output = Content.Output?
            public typealias Buffer = Content.Buffer
            public typealias Failure = Content.Failure
            public let content: Content
            public let rejected: (Failure) -> Bool
            public init(_ content: consuming Content, rejected: @escaping (Failure) -> Bool) {
                self.content = content
                self.rejected = rejected
            }
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let checkpoint = input.checkpoint
                do throws(Failure) { return try content.parse(&input) } catch {
                    guard rejected(error) else { throw error }
                    input.seek(to: checkpoint)
                    return nil
                }
            }
            public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                switch output {
                case .none: return
                case .some(let value): try content.serialize(value, into: &buffer)
                }
            }
        }
    }
    extension OneOf.Optional: Copyable
    where
        Content: Coding<Content.Input, Content.Output, Content.Buffer, Content.Failure> & Copyable,
        Content.Input: Restorable & ~Copyable & ~Escapable, Content.Output: ~Copyable,
        Content.Buffer: ~Copyable & ~Escapable
    {}

    extension Coding
    where
        Self: ~Copyable, Input: Restorable & ~Copyable & ~Escapable,
        Output: ~Copyable & Escapable, Buffer: ~Copyable & ~Escapable
    {
        public consuming func optional(rejected: @escaping (Failure) -> Bool) -> OneOf.Optional<Self> {
            .init(self, rejected: rejected)
        }
    }
#endif
