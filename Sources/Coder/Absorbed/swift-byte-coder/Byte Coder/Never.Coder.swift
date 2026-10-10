#if Byte
public import Coder_Core
public import Byte

import Parser
import Serializer

extension Swift.Never {

    public struct Coder: Byte.Coding<Swift.Never, Swift.Never.Coder.Error> {


        public typealias Buffer = [Byte]

        public enum Error: Swift.Error, Equatable {
            case absent
        }

        @inlinable
        public init() {}

        @inlinable
        public borrowing func parse(
            _ input: inout ArraySlice<Byte>
        ) throws(Swift.Never.Coder.Error) -> Swift.Never {
            throw .absent
        }

        @inlinable
        public borrowing func serialize<Buffer: RangeReplaceableCollection>(
            _ output: Swift.Never,
            into buffer: inout Buffer
        ) throws(Swift.Never.Coder.Error) where Buffer.Element == Byte {
            switch output {}
        }
    }
}
#endif
