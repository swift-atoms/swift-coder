public import Either
public import Parser
public import Serializer_Core

extension Parser.Take.Two: @retroactive Serializer.`Protocol`
where P0: Serializer.`Protocol`, P1: Serializer.`Protocol`, P0.Buffer == P1.Buffer {

    public typealias Buffer = P0.Buffer

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(
        _ output: (P0.Output, P1.Output),
        into buffer: inout Buffer
    ) throws(Either<P0.Failure, P1.Failure>) {
        do throws(P0.Failure) {
            try p0.serialize(output.0, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            try p1.serialize(output.1, into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}
