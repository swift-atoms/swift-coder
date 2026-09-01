public import Either
public import Parser
public import Parser_Skip
public import Serializer

extension Parser.Skip.Second: @retroactive Serializer.`Protocol`
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
        _ output: P0.Output,
        into buffer: inout Buffer
    ) throws(Either<P0.Failure, P1.Failure>) {
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            try p1.serialize((), into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}
