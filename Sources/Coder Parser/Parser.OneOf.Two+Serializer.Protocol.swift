public import Cursor_Parser_OneOf
public import Parser
public import Product
public import Serializer

extension Parser.OneOf.Two: @retroactive Serializer.`Protocol`
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
        _ output: Output,
        into buffer: inout Buffer
    ) throws(Product<P0.Failure, P1.Failure>) {
        let checkpoint = buffer
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
            return
        } catch let error0 {
            buffer = checkpoint
            do throws(P1.Failure) {
                try p1.serialize(output, into: &buffer)
            } catch let error1 {
                buffer = checkpoint
                throw Product(error0, error1)
            }
        }
    }
}
