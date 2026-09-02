import Parser
import Serializer

extension Coder {

    public struct Witness<
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable,
        Buffer: ~Copyable & ~Escapable,
        Failure: Swift.Error
    >: Coder.`Protocol` {

        @usableFromInline
        var _parse: (inout Input) throws(Failure) -> Output

        @usableFromInline
        var _serialize: (borrowing Output, inout Buffer) throws(Failure) -> Void

        @inlinable
        public init(
            parse: @escaping (inout Input) throws(Failure) -> Output,
            serialize: @escaping (borrowing Output, inout Buffer) throws(Failure) -> Void
        ) {
            self._parse = parse
            self._serialize = serialize
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try _parse(&input)
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            try _serialize(output, &buffer)
        }
    }

    public typealias Pure<Input, Output, Buffer> = Witness<Input, Output, Buffer, Never>
    where Input: ~Copyable & ~Escapable, Output: ~Copyable, Buffer: ~Copyable & ~Escapable
}
