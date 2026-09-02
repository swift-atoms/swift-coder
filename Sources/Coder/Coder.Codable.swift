public import Parser
public import Serializer

extension Coder {

    public protocol Codable {

        associatedtype Coding: Coder::Coder.`Protocol`
        where
            Coding.Input: ~Copyable & ~Escapable,
            Coding.Output: ~Copyable & ~Escapable,
            Coding.Buffer: ~Copyable & ~Escapable

        static var coder: Coding { get }
    }
}

extension Coder.Codable
where
    Coding.Output == Self,
    Coding.Input: ~Copyable & ~Escapable,
    Coding.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public func encode(into buffer: inout Coding.Buffer) throws(Coding.Failure) {
        try Self.coder.serialize(self, into: &buffer)
    }

    @inlinable
    public init(decoding input: inout Coding.Input) throws(Coding.Failure) {
        self = try Self.coder.parse(&input)
    }
}
