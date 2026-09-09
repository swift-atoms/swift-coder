public import Parser
public import Serializer

extension Map::Map.Error.Parser: Serializer.`Protocol`
where
    Upstream: Serializer.`Protocol`,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = Upstream.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Target) {
        do throws(Upstream.Failure) {
            try upstream.serialize(output, into: &buffer)
        } catch {
            throw base(error)
        }
    }
}

extension Map::Map.Error.Parser: Coder.`Protocol`
where
    Upstream: Coder.`Protocol`,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{}
