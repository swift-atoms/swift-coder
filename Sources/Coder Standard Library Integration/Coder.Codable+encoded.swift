public import Serializer
public import Coder

extension Coder.Codable where Coder.Output == Self, Coder.Buffer: RangeReplaceableCollection {

    @inlinable
    public func encoded() throws(Coder.Failure) -> Coder.Buffer {
        var buffer = Coder.Buffer()
        try Self.coder.serialize(self, into: &buffer)
        return buffer
    }
}
