#if Carrier
public import Map
public import Carrier

public import Parser
public import Serializer

extension Coding
where
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & Escapable,
    Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func map<Value: Carrier.`Protocol`>(
        representing _: Value.Type
    ) -> Map<Output, Value, Failure>.Coder<Self>
    where Value.Underlying == Output {
        map(to: { Value($0) }, from: { value in value.underlying })
    }
}
#endif
