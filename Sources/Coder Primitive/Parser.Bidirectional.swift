public import Parser
public import Serializer

extension Parser {

    public protocol Bidirectional<Input, Output, Failure>: Coder.`Protocol`, ~Copyable
    where Buffer == Input {}
}
