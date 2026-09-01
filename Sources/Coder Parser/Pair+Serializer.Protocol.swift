public import Either
public import Pair
public import Parser
public import Serializer

extension Pair: @retroactive Serializer.`Protocol`
where
    First: Parser.`Protocol` & Serializer.`Protocol`,
    Second: Parser.`Protocol` & Serializer.`Protocol`,
    First.Input == Second.Input,
    First.Buffer == Second.Buffer
{

    public typealias Buffer = First.Buffer

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public borrowing func serialize(
        _ output: (First.Output, Second.Output),
        into buffer: inout First.Buffer
    ) throws(Either<First.Failure, Second.Failure>) {
        do throws(First.Failure) {
            try first.serialize(output.0, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(Second.Failure) {
            try second.serialize(output.1, into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}
