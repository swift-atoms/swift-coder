public import Cursor_Parser_First
public import Parser
public import Serializer

extension Parser.First.Element: @retroactive Serializer.`Protocol`
where Input: RangeReplaceableCollection {

    public typealias Buffer = Input

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(_ output: Input.Element, into buffer: inout Input) {
        buffer.append(output)
    }
}
