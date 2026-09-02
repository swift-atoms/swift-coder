public import Parser
public import Serializer

extension Coder {

    public protocol `Protocol`<Input, Output, Buffer, Failure>:
        Parser.`Protocol`,
        Serializer.`Protocol`,
        ~Copyable
    where
        Self.Input: ~Copyable & ~Escapable
    {}
}
