public import Either
public import Parser
public import Serializer

extension Parser::Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildIf<P: Coding>(
        _ coder: P?
    ) -> Swift.Optional<P>.Coder
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable,
        P.Buffer: ~Copyable & ~Escapable
    {
        .init(coder)
    }
}

extension Coder::Coder.Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {

    @inlinable
    public static func buildIf<P: Coding>(
        _ coder: P?
    ) -> Swift.Optional<P>.Coder
    where
        P.Input == Input,
        P.Buffer == Buffer,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable,
        P.Buffer: ~Copyable & ~Escapable
    {
        .init(coder)
    }
}
