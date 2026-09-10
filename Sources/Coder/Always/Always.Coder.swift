#if Always
    public import Always

    extension Always where Value == Void {
        /// The unit grammar: no input or output, exactly Never failure.
        /// Arbitrary Always values remain one-way; no discarded value is invented.
        public struct Coder<Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable>: Coding {
            public typealias Output = Void
            public typealias Failure = Never
            public init() {}
            public borrowing func parse(_ input: inout Input) {}
            public borrowing func serialize(_ output: Void, into buffer: inout Buffer) {}
        }
        public func coder<Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable>(
            for input: Input.Type = Input.self, into buffer: Buffer.Type = Buffer.self
        ) -> Coder<Input, Buffer> { .init() }
    }

    extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
        public static func buildExpression(_ unit: Always<Void>) -> Always<Void>.Coder<Input, Buffer> {
            .init()
        }
    }
#endif
