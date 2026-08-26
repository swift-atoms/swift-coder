public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Error.Map: @retroactive Serializer.`Protocol`
where Upstream: Serializer.`Protocol` {

    public typealias Buffer = Upstream.Buffer

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(
        _ output: Output,
        into buffer: inout Buffer
    ) throws(NewFailure) {
        do throws(Upstream.Failure) {
            try upstream.serialize(output, into: &buffer)
        } catch {
            throw transform(error)
        }
    }
}
