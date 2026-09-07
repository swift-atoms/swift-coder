public import Parser
public import Serializer

extension Parser.Sequence: Serializer.`Protocol`
where
    Body: Serializer.`Protocol`,
    Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & ~Escapable,
    Body.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = Body.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}

extension Parser.Sequence: Coder.`Protocol`
where
    Body: Coder.`Protocol`,
    Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & ~Escapable,
    Body.Buffer: ~Copyable & ~Escapable
{}
