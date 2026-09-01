public import Parser
public import Serializer

extension Coder {

    public protocol `Protocol`:
        Parser.`Protocol`,
        Serializer.`Protocol`,
        ~Copyable
    where
        Self.Input: ~Copyable & ~Escapable
    {}
}
