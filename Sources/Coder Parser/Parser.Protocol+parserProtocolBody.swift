import Parser

extension Parser.`Protocol` where Self: ~Copyable, Body: Copyable {

    internal var parserProtocolBody: Body { body }
}
