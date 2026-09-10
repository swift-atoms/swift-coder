/// A bidirectional grammar represented by two typed functions.
/// Parsing consumes its cursor; serialization borrows its value and writes forward.
public struct Coder<
    Input: ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable,
    Buffer: ~Copyable & ~Escapable, Failure: Swift.Error
>: Coding {
    public var _parse: @_lifetime(&input) (_ input: inout Input) throws(Failure) -> Output
    public var _serialize: (borrowing Output, inout Buffer) throws(Failure) -> Void

    @_disfavoredOverload
    @inlinable public init(
        parse: @escaping @_lifetime(&input) (_ input: inout Input) throws(Failure) -> Output,
        serialize: @escaping (borrowing Output, inout Buffer) throws(Failure) -> Void
    ) {
        self._parse = parse
        self._serialize = serialize
    }

    /// An infallible borrowed writer shares the parser's exact failure type.
    @inlinable public init(
        parse: @escaping @_lifetime(&input) (_ input: inout Input) throws(Failure) -> Output,
        serialize: @escaping (borrowing Output, inout Buffer) -> Void
    ) {
        self._parse = parse
        self._serialize = { value, buffer throws(Failure) in serialize(value, &buffer) }
    }

    @inlinable @_lifetime(borrow self, &input)
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output { try _parse(&input) }

    @inlinable public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
        throws(Failure)
    {
        try _serialize(output, &buffer)
    }
}

extension Coder
where
    Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable,
    Buffer: ~Copyable & ~Escapable
{
    /// Retains a copyable composition in both directions. Concrete Coding bodies
    /// also support noncopyable components without this closure representation.
    @inlinable public init<C: Coding>(@Builder<Input, Buffer> _ build: () -> C)
    where
        C.Input == Input, C.Output == Output, C.Buffer == Buffer, C.Failure == Failure,
        C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable, C.Buffer: ~Copyable & ~Escapable
    {
        let composition = build()
        self.init(
            parse: { input throws(Failure) in try composition.parse(&input) },
            serialize: { output, buffer throws(Failure) in try composition.serialize(output, into: &buffer) })
    }

    /// Supplies cursor/buffer context when a unit grammar cannot infer them.
    @inlinable public init<C: Coding>(
        _ input: Input.Type, _ buffer: Buffer.Type,
        @Builder<Input, Buffer> _ build: () -> C
    )
    where
        C.Input == Input, C.Output == Output, C.Buffer == Buffer, C.Failure == Failure,
        C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable, C.Buffer: ~Copyable & ~Escapable
    {
        self.init(build)
    }

    @inlinable public init<C: Coding>(
        _ forward: @escaping (consuming C.Output) -> Output,
        from backward: @escaping (borrowing Output) -> C.Output,
        @Builder<Input, Buffer> _ build: () -> C
    )
    where
        C.Input == Input, C.Buffer == Buffer, C.Failure == Failure,
        C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable & Escapable, C.Buffer: ~Copyable & ~Escapable
    {
        self.init(
            { value throws(Failure) in forward(value) },
            from: { value throws(Failure) in backward(value) }, build)
    }

    /// Construction has an explicit borrowed reverse projection; an initializer
    /// alone is deliberately insufficient to construct a coder.
    @_disfavoredOverload
    @inlinable public init<C: Coding>(
        _ forward: @escaping (consuming C.Output) throws(Failure) -> Output,
        from backward: @escaping (borrowing Output) throws(Failure) -> C.Output,
        @Builder<Input, Buffer> _ build: () -> C
    )
    where
        C.Input == Input, C.Buffer == Buffer, C.Failure == Failure,
        C.Input: ~Copyable & ~Escapable, C.Output: ~Copyable & Escapable, C.Buffer: ~Copyable & ~Escapable
    {
        let composition = build()
        self.init(
            parse: { input throws(Failure) in try forward(composition.parse(&input)) },
            serialize: { output, buffer throws(Failure) in
                try composition.serialize(backward(output), into: &buffer)
            })
    }
}
