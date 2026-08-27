extension Coder {

    public struct Witness<
        Input: ~Copyable & ~Escapable,
        Output,
        Buffer,
        Failure: Swift.Error
    > {
        @usableFromInline
        var _parse: (inout Input) throws(Failure) -> Output

        @usableFromInline
        var _serialize: (Output, inout Buffer) throws(Failure) -> Void

        @inlinable
        public init(
            parse: @escaping (inout Input) throws(Failure) -> Output,
            serialize: @escaping (Output, inout Buffer) throws(Failure) -> Void
        ) {
            self._parse = parse
            self._serialize = serialize
        }
    }
}

extension Coder.Witness: Coder.`Protocol` {

    public typealias Body = Never

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError(
                "Coder.Witness is a leaf — parse(_:) and serialize(_:into:) are implemented directly via stored closures"
            )
        }
    }

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        try _parse(&input)
    }

    @inlinable
    public borrowing func serialize(_ value: Output, into buffer: inout Buffer) throws(Failure) {
        try _serialize(value, &buffer)
    }
}

extension Coder {

    public typealias Pure<Input, Output, Buffer> = Witness<Input, Output, Buffer, Never>
    where Input: ~Copyable & ~Escapable
}
