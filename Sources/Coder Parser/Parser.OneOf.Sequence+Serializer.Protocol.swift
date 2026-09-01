public import Cursor_Parser_OneOf
public import Parser
public import Serializer

extension Parser.OneOf.Sequence: @retroactive Serializer.`Protocol`
where Body: Serializer.`Protocol` {

    public typealias Buffer = Body.Buffer

    public var body: Body { parserProtocolBody }

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}
