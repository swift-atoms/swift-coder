public import Always
public import Always_Parser
public import Parser
public import Serializer

extension Always.Parser: @retroactive Serializer.`Protocol` where Value == Void {

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
