#if Optic
    import Either
    public import Optic
    public import Parser
    public import Serializer

    public struct Case<
        Input: ~Copyable & ~Escapable,
        Source: ~Copyable,
        Focus: ~Copyable,
        Content: Coding & ~Copyable
    >: ~Copyable
    where
        Content.Input == Input,
        Content.Output == Focus,
        Content.Buffer: ~Copyable & ~Escapable
    {
        public let prism: Optic::Optic<Source, Source, Focus, Focus>.Prism

        public let fold: Optic::Optic<Source, Source, Focus, Focus>.Fold

        public let absent: Content.Failure

        public let content: Content

        @inlinable
        public init<Buffer: ~Copyable & ~Escapable>(
            _ prism: Optic::Optic<Source, Source, Focus, Focus>.Prism,
            _ fold: Optic::Optic<Source, Source, Focus, Focus>.Fold,
            absent: Content.Failure,
            @Builder<Input, Buffer> content: () -> Content
        ) where Content.Buffer == Buffer {
            self.prism = prism
            self.fold = fold
            self.absent = absent
            self.content = content()
        }
    }

    extension Case
    where
        Input: ~Copyable & ~Escapable,
        Source: Copyable,
        Focus: ~Copyable,
        Content: ~Copyable,
        Content.Buffer: ~Copyable & ~Escapable
    {

        @inlinable
        public init<Buffer: ~Copyable & ~Escapable>(
            _ prism: Optic::Optic<Source, Source, Focus, Focus>.Prism,
            absent: Content.Failure,
            @Builder<Input, Buffer> content: () -> Content
        ) where Content.Buffer == Buffer {
            self.init(prism, .init(prism), absent: absent, content: content)
        }
    }

    extension Case: Parsing
    where
        Input: ~Copyable & ~Escapable,
        Source: ~Copyable,
        Focus: ~Copyable,
        Content: ~Copyable,
        Content.Buffer: ~Copyable & ~Escapable
    {

        public typealias Output = Source

        public typealias Failure = Content.Failure

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            prism.embed(try content.parse(&input))
        }
    }

    extension Case: Serializing
    where
        Input: ~Copyable & ~Escapable,
        Source: ~Copyable,
        Focus: ~Copyable,
        Content: ~Copyable,
        Content.Buffer: ~Copyable & ~Escapable
    {

        public typealias Buffer = Content.Buffer

        @inlinable
        public borrowing func serialize(_ output: borrowing Source, into buffer: inout Buffer) throws(Failure)
        {
            var failure: Failure? = nil
            let visited = fold.visit(output) { focus in
                do throws(Failure) {
                    try self.content.serialize(focus, into: &buffer)
                } catch {
                    failure = error
                }
            }
            guard visited else {
                throw absent
            }
            if let failure {
                throw failure
            }
        }
    }

    extension Case: Coding
    where
        Input: ~Copyable & ~Escapable,
        Source: ~Copyable,
        Focus: ~Copyable,
        Content: ~Copyable,
        Content: ~Copyable,
        Content.Buffer: ~Copyable & ~Escapable
    {}

    extension Case: Copyable
    where
        Input: ~Copyable & ~Escapable, Source: ~Copyable, Focus: ~Copyable,
        Content: Coding<Content.Input, Content.Output, Content.Buffer, Content.Failure> & Copyable,
        Content.Input: ~Copyable & ~Escapable, Content.Output: ~Copyable,
        Content.Buffer: ~Copyable & ~Escapable
    {}
#endif
