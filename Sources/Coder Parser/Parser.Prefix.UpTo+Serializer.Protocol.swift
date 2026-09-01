public import Collection_Parser_Prefix
public import Parser
public import Serializer

extension Parser.Prefix.UpTo: @retroactive Serializer.`Protocol`
where Input: RangeReplaceableCollection {

    public typealias Buffer = Input

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(_ output: Input, into buffer: inout Input) {
        buffer.append(contentsOf: output)
    }
}
