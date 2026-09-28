#if Byte
public import Byte


import Parser
import Serializer

extension Swift.String {

    public struct Coder: Byte.Coding<Swift.String, Swift.String.Coder.Error> {

        public typealias Buffer = [Byte]

        @inlinable
        public init() {}

        @inlinable
        public borrowing func parse(
            _ input: inout ArraySlice<Byte>
        ) throws(Swift.String.Coder.Error) -> Swift.String {
            var raw: [UInt8] = []
            while let byte = input.popFirst() {
                raw.append(byte.bitPattern)
            }
            guard let text = Swift.String(validating: raw, as: Swift.UTF8.self) else {
                throw .invalid
            }
            return text
        }

        @inlinable
        public borrowing func serialize<Buffer: RangeReplaceableCollection>(
            _ output: Swift.String,
            into buffer: inout Buffer
        ) throws(Swift.String.Coder.Error) where Buffer.Element == Byte {
            buffer.append(contentsOf: output.utf8.lazy.map(Byte.init(bitPattern:)))
        }
    }
}
#endif
