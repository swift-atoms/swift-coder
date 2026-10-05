public import Parser
public import Serializer

public protocol Coding<Input, Output, Buffer, Failure>: Parsing, Serializing, ~Copyable
where Input: ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
    @Builder<Input, Buffer>
    var body: Body { borrowing get }
}

