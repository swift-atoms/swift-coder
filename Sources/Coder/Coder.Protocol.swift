public import Parser
public import Serializer

extension Coder {

    public protocol `Protocol`<Input, Output, Buffer, Failure>:
        Parsing,
        Serializer.`Protocol`,
        ~Copyable
    where
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable & ~Escapable,
        Buffer: ~Copyable & ~Escapable
    {}
}

extension Coder.`Protocol`
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable,
    Buffer: ~Copyable & ~Escapable,
    Body: Coder.`Protocol`<Input, Output, Buffer, Failure>
{

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}
