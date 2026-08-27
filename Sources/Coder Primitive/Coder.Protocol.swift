public import Parser_Core
public import Serializer_Core

extension Coder {

    public protocol `Protocol`<Input, Output, Buffer, Failure>:
        Parser.`Protocol`<Self.Input, Self.Output, Self.Failure>,
        Serializer.`Protocol`<Self.Output, Self.Buffer, Self.Failure>,
        ~Copyable
    where
        Self.Input: ~Copyable & ~Escapable
    {}
}
