public import Coder
public import Serializer

extension Coder.Codable
where
    Coder.Output == Self,
    Coder.Input: ~Copyable & ~Escapable,
    Coder.Buffer: RangeReplaceableCollection
{

    @inlinable
    public func encoded() throws(Coder.Failure) -> Coder.Buffer {
        var buffer = Coder.Buffer()
        try Self.coder.serialize(self, into: &buffer)
        return buffer
    }
}
