public import Coder
public import Serializer

extension Coder.Codable
where
    Coding.Output == Self,
    Coding.Input: ~Copyable & ~Escapable,
    Coding.Buffer: RangeReplaceableCollection
{

    @inlinable
    public func encoded() throws(Coding.Failure) -> Coding.Buffer {
        var buffer = Coding.Buffer()
        try Self.coder.serialize(self, into: &buffer)
        return buffer
    }
}
