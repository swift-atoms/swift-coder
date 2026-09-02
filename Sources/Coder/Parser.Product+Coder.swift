public import Pair
public import Parser
public import Parser_Product
public import Serializer

extension Parser.Product: Serializer.`Protocol`
where
    P0: Serializer.`Protocol`,
    P1: Serializer.`Protocol`,
    P0.Buffer == P1.Buffer,
    P0.Input: ~Copyable & ~Escapable,
    P1.Input: ~Copyable & ~Escapable,
    P0.Output: ~Copyable & Escapable,
    P1.Output: ~Copyable & Escapable,
    P0.Buffer: ~Copyable & ~Escapable,
    P1.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = P0.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        do throws(P0.Failure) {
            try p0.serialize(output.first, into: &buffer)
        } catch {
            throw failure0(error)
        }
        do throws(P1.Failure) {
            try p1.serialize(output.second, into: &buffer)
        } catch {
            throw failure1(error)
        }
    }
}

extension Parser.Product: Coder.`Protocol`
where
    P0: Coder.`Protocol`,
    P1: Coder.`Protocol`,
    P0.Buffer == P1.Buffer,
    P0.Input: ~Copyable & ~Escapable,
    P1.Input: ~Copyable & ~Escapable,
    P0.Output: ~Copyable & Escapable,
    P1.Output: ~Copyable & Escapable,
    P0.Buffer: ~Copyable & ~Escapable,
    P1.Buffer: ~Copyable & ~Escapable
{}
