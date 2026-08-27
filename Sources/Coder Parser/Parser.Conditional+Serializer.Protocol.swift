public import Either
public import Parser
public import Serializer_Core

extension Parser.Conditional: @retroactive Serializer.`Protocol`
where First: Serializer.`Protocol`, Second: Serializer.`Protocol`, First.Buffer == Second.Buffer {

    public typealias Buffer = First.Buffer

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
    ) throws(Either<First.Failure, Second.Failure>) {
        switch self {
        case .first(let serializer):
            do throws(First.Failure) {
                try serializer.serialize(output, into: &buffer)
            } catch {
                throw .left(error)
            }

        case .second(let serializer):
            do throws(Second.Failure) {
                try serializer.serialize(output, into: &buffer)
            } catch {
                throw .right(error)
            }
        }
    }
}
