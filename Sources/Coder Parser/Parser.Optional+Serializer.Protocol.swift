public import Parser
public import Serializer_Core

extension Parser.Optional: @retroactive Serializer.`Protocol`
where Wrapped: Serializer.`Protocol` {

    public typealias Buffer = Wrapped.Buffer

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(
        _ output: Wrapped.Output?,
        into buffer: inout Buffer
    ) throws(Wrapped.Failure) {
        guard let wrapped, let output else { return }
        try wrapped.serialize(output, into: &buffer)
    }
}
