public import Parser
public import Serializer

extension Parser.Error.Map: Serializer.`Protocol`
where
    Upstream: Serializer.`Protocol`,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = Upstream.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(NewFailure) {
        do throws(Upstream.Failure) {
            try upstream.serialize(output, into: &buffer)
        } catch {
            throw transform(error)
        }
    }
}

extension Parser.Error.Map: Coder.`Protocol`
where
    Upstream: Coder.`Protocol`,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{}
