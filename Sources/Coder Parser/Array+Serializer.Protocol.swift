import Parser
public import Serializer

extension Swift.Array: @retroactive Serializer.`Protocol` where Element: Equatable {

    public typealias Buffer = ArraySlice<Element>

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(_ output: Void, into buffer: inout ArraySlice<Element>) {
        buffer.append(contentsOf: self)
    }
}
