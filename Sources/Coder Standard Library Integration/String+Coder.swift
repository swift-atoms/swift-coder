public import Coder
import Parser
public import Parser_Standard_Library_Integration
public import Serializer

extension Swift.String: @retroactive Serializer.`Protocol` {

    public typealias Buffer = Substring

    @inlinable
    public borrowing func serialize(_ output: Void, into buffer: inout Substring) throws(Failure) {
        buffer.append(contentsOf: self)
    }
}

extension Swift.String: Coder.`Protocol` {}
