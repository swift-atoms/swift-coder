import Parser

extension Parser.`Protocol`
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Body: Copyable
{

    internal var parserProtocolBody: Body { body }
}
