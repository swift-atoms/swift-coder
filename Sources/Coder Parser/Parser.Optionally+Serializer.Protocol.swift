public import Cursor_Parser_Optionally
public import Parser
public import Serializer

extension Parser.Optionally: @retroactive Serializer.`Protocol`
where Wrapped: Serializer.`Protocol` {

    public typealias Buffer = Wrapped.Buffer

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(_ output: Wrapped.Output?, into buffer: inout Buffer) {
        guard let output else { return }
        let checkpoint = buffer
        do throws(Wrapped.Failure) {
            try wrapped.serialize(output, into: &buffer)
        } catch {
            buffer = checkpoint
        }
    }
}
