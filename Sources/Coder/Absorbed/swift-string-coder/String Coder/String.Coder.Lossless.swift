#if Byte
public import Byte


import Parser
import Serializer

extension Swift.String.Coder {

    public struct Lossless<
        Value: LosslessStringConvertible
    >: Byte.Coding<Value, Swift.String.Coder.Error> {


        public let text: Swift.String.Coder

        public typealias Buffer = [Byte]

        @inlinable
        public init() {
            self.text = .init()
        }

        @inlinable
        public borrowing func parse(
            _ input: inout ArraySlice<Byte>
        ) throws(Swift.String.Coder.Error) -> Value {
            let description = try text.parse(&input)
            guard let value = Value(description) else {
                throw .malformed
            }
            return value
        }

        @inlinable
        public borrowing func serialize<Buffer: RangeReplaceableCollection>(
            _ output: Value,
            into buffer: inout Buffer
        ) throws(Swift.String.Coder.Error) where Buffer.Element == Byte {
            try text.serialize(output.description, into: &buffer)
        }
    }
}
#endif
