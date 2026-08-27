public import Either
public import Parser
public import Serializer_Core

extension Parser.Converted: @retroactive Serializer.`Protocol`
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
    ) throws(Either<Upstream.Failure, Downstream.Failure>) {
        let upstreamOutput: Upstream.Output
        do throws(Downstream.Failure) {
            upstreamOutput = try downstream.unapply(output)
        } catch {
            throw .right(error)
        }
        do throws(Upstream.Failure) {
            try upstream.serialize(upstreamOutput, into: &buffer)
        } catch {
            throw .left(error)
        }
    }
}
