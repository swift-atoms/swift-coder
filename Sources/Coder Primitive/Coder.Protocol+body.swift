public import Parser
public import Serializer

extension Parser.`Protocol` where Self: ~Copyable {

    @inlinable
    @usableFromInline
    internal var __parserBody: Body {
        _read { yield body }
    }
}

extension Coder.`Protocol` where Self: ~Copyable {

    @inlinable
    @_implements(Serializer.`Protocol`,body)
    public var __serializerBody: Body {
        _read { yield __parserBody }
    }
}

extension Coder.`Protocol` where Self: ~Copyable, Body == Never {

    @inlinable
    @_implements(Parser.`Protocol`,body)
    public var __parserLeafBody: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf coder — implement parse(_:) directly")
        }
    }
}
