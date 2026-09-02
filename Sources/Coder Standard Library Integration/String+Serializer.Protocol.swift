import Parser
import Parser_Standard_Library_Integration
public import Serializer

extension Swift.String: @retroactive Serializer.`Protocol` {

    public typealias Buffer = Substring

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(_ output: Void, into buffer: inout Substring) {
        buffer.append(contentsOf: self)
    }
}
