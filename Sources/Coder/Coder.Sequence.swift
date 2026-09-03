public import Parser
public import Serializer

extension Coder {

    public struct Sequence<
        Input: ~Copyable & ~Escapable,
        Buffer: ~Copyable & ~Escapable,
        Body: Coder.`Protocol`
    >: Coder.`Protocol`
    where
        Body.Input == Input,
        Body.Buffer == Buffer,
        Body.Output: ~Copyable & ~Escapable
    {
        public typealias Output = Body.Output

        public typealias Failure = Body.Failure

        public let body: Body

        @inlinable
        public init(
            _: Input.Type = Input.self,
            _: Buffer.Type = Buffer.self,
            @Coder.Builder<Input, Buffer> _ build: () -> Body
        ) {
            self.body = build()
        }

        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try body.parse(&input)
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            try body.serialize(output, into: &buffer)
        }
    }
}
