public import Parser
public import Serializer

extension Coder {

    public protocol Codable {

        associatedtype Coder: Coder::Coder.`Protocol`
        where Coder.Input: ~Copyable & ~Escapable

        static var coder: Coder { get }
    }
}

extension Coder.Codable where Coder.Output == Self {

    @inlinable
    public func encode(into buffer: inout Coder.Buffer) throws(Coder.Failure) {
        try Self.coder.serialize(self, into: &buffer)
    }

    @inlinable
    public init(decoding input: inout Coder.Input) throws(Coder.Failure) {
        self = try Self.coder.parse(&input)
    }
}
