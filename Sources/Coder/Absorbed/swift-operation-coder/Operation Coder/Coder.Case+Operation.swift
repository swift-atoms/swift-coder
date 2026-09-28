#if Operation
public import Operation
public import Optic
public import Parser
public import Serializer

extension Coder::Case
where
    Input: ~Copyable & ~Escapable,
    Source: ~Copyable,
    Focus: ~Copyable,
    Content.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public init(
        _ prism: Optic::Optic<Source, Source, Focus, Focus>.Prism,
        _ fold: Optic::Optic<Source, Source, Focus, Focus>.Fold,
        absent: Content.Failure,
        content: Content
    ) {
        self.init(prism, fold, absent: absent) { content }
    }

    @inlinable
    public init<Buffer: ~Copyable & ~Escapable>(
        _ case: Optic::Optic<Source, Source, Focus, Focus>.Case,
        absent: Content.Failure,
        @Coder::Builder<Input, Buffer> content: () -> Content
    ) where Content.Buffer == Buffer {
        self.init(`case`.prism, `case`.fold, absent: absent, content: content)
    }

    @inlinable
    public init(
        _ case: Optic::Optic<Source, Source, Focus, Focus>.Case,
        absent: Content.Failure,
        content: Content
    ) {
        self.init(`case`.prism, `case`.fold, absent: absent) { content }
    }
}

extension Coder::Case
where
    Input: ~Copyable & ~Escapable,
    Source: Operation.Coproduct & ~Copyable,
    Focus: ~Copyable,
    Content.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public init<Buffer: ~Copyable & ~Escapable>(
        _ keyPath: KeyPath<Source.Cases, Optic::Optic<Source, Source, Focus, Focus>.Case>,
        absent: Content.Failure,
        @Coder::Builder<Input, Buffer> content: () -> Content
    ) where Content.Buffer == Buffer {
        self.init(Source.cases[keyPath: keyPath], absent: absent, content: content)
    }

    @inlinable
    public init(
        _ keyPath: KeyPath<Source.Cases, Optic::Optic<Source, Source, Focus, Focus>.Case>,
        absent: Content.Failure,
        content: Content
    ) {
        self.init(Source.cases[keyPath: keyPath], absent: absent) { content }
    }
}

extension Coder::Case
where
    Input: ~Copyable & ~Escapable,
    Source: ~Copyable,
    Focus: ~Copyable,
    Content.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public init<Index: Operation.Symbol, Inner: Coding>(
        _ prism: Optic::Optic<Source, Source, Focus, Focus>.Prism,
        _ fold: Optic::Optic<Source, Source, Focus, Focus>.Fold,
        absent: Content.Failure,
        content: Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input: ~Copyable & ~Escapable,
        Inner.Buffer: ~Copyable & ~Escapable,
        Inner.Input == Input,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable
    {
        self.init(prism, fold, absent: absent) { Content(content) }
    }

    @inlinable
    public init<Index: Operation.Symbol, Inner: Coding, Buffer: ~Copyable & ~Escapable>(
        _ prism: Optic::Optic<Source, Source, Focus, Focus>.Prism,
        _ fold: Optic::Optic<Source, Source, Focus, Focus>.Fold,
        absent: Content.Failure,
        @Coder::Builder<Input, Buffer> content: () -> Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input: ~Copyable & ~Escapable,
        Inner.Buffer: ~Copyable & ~Escapable,
        Inner.Input == Input,
        Inner.Buffer == Buffer,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable
    {
        self.init(prism, fold, absent: absent) { Content(content()) }
    }

    @inlinable
    public init<Index: Operation.Symbol, Inner: Coding>(
        _ case: Optic::Optic<Source, Source, Focus, Focus>.Case,
        absent: Content.Failure,
        content: Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input: ~Copyable & ~Escapable,
        Inner.Buffer: ~Copyable & ~Escapable,
        Inner.Input == Input,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable
    {
        self.init(`case`.prism, `case`.fold, absent: absent, content: content)
    }

    @inlinable
    public init<Index: Operation.Symbol, Inner: Coding, Buffer: ~Copyable & ~Escapable>(
        _ case: Optic::Optic<Source, Source, Focus, Focus>.Case,
        absent: Content.Failure,
        @Coder::Builder<Input, Buffer> content: () -> Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input: ~Copyable & ~Escapable,
        Inner.Buffer: ~Copyable & ~Escapable,
        Inner.Input == Input,
        Inner.Buffer == Buffer,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable
    {
        self.init(`case`.prism, `case`.fold, absent: absent, content: content())
    }
}

extension Coder::Case
where
    Input: ~Copyable & ~Escapable,
    Source: Operation.Coproduct & ~Copyable,
    Focus: ~Copyable,
    Content.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public init<Index: Operation.Symbol, Inner: Coding>(
        _ keyPath: KeyPath<Source.Cases, Optic::Optic<Source, Source, Focus, Focus>.Case>,
        absent: Content.Failure,
        content: Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input: ~Copyable & ~Escapable,
        Inner.Buffer: ~Copyable & ~Escapable,
        Inner.Input == Input,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable
    {
        self.init(Source.cases[keyPath: keyPath], absent: absent, content: content)
    }

    @inlinable
    public init<Index: Operation.Symbol, Inner: Coding, Buffer: ~Copyable & ~Escapable>(
        _ keyPath: KeyPath<Source.Cases, Optic::Optic<Source, Source, Focus, Focus>.Case>,
        absent: Content.Failure,
        @Coder::Builder<Input, Buffer> content: () -> Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input: ~Copyable & ~Escapable,
        Inner.Buffer: ~Copyable & ~Escapable,
        Inner.Input == Input,
        Inner.Buffer == Buffer,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable
    {
        self.init(Source.cases[keyPath: keyPath], absent: absent, content: content())
    }
}
#endif
