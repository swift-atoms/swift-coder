public import Parser
public import Parser_Skip
public import Serializer

extension Parser.Skip.First: Serializer.`Protocol`
where
    S: Serializer.`Protocol`,
    V: Serializer.`Protocol`,
    S.Buffer == V.Buffer,
    S.Input: ~Copyable & ~Escapable,
    V.Input: ~Copyable & ~Escapable,
    V.Output: ~Copyable & ~Escapable,
    S.Buffer: ~Copyable & ~Escapable,
    V.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = S.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        do throws(S.Failure) {
            try skipped.serialize((), into: &buffer)
        } catch {
            throw skippedFailure(error)
        }
        do throws(V.Failure) {
            try value.serialize(output, into: &buffer)
        } catch {
            throw valueFailure(error)
        }
    }
}

extension Parser.Skip.First: Coder.`Protocol`
where
    S: Coder.`Protocol`,
    V: Coder.`Protocol`,
    S.Buffer == V.Buffer,
    S.Input: ~Copyable & ~Escapable,
    V.Input: ~Copyable & ~Escapable,
    V.Output: ~Copyable & ~Escapable,
    S.Buffer: ~Copyable & ~Escapable,
    V.Buffer: ~Copyable & ~Escapable
{}
