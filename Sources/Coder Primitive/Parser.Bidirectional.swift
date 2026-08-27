public import Parser_Core
public import Serializer_Core

extension Parser {

    public protocol Bidirectional<Input, Output, Failure>: Coder.`Protocol`, ~Copyable
    where Buffer == Input {}
}
