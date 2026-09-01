public import Collection_Parser_End
public import Parser
public import Serializer

extension Parser.End: @retroactive Serializer.`Protocol` {

    public typealias Buffer = Input

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(_ output: Void, into buffer: inout Input) {

    }
}
