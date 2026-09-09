public import Parser
public import Serializer

extension Parser::Sequence.Parser: Serializer.`Protocol`
where
    Body: Serializer.`Protocol`,
    Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & ~Escapable,
    Body.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = Body.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        try base.body.serialize(output, into: &buffer)
    }
}

extension Parser::Sequence.Parser: Coder.`Protocol`
where
    Body: Coder.`Protocol`,
    Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & ~Escapable,
    Body.Buffer: ~Copyable & ~Escapable
{}
