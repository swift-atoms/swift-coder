public import Skip_Parser
public import Parser
public import Serializer

extension Skip::Skip.Parser: Serializer.`Protocol`
where
    Kept: ~Copyable & Escapable,
    Dropped == Void,
    A: Serializer.`Protocol`,
    N: Serializer.`Protocol`,
    A.Buffer == N.Buffer,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable,
    A.Output: ~Copyable & Escapable,
    A.Buffer: ~Copyable & ~Escapable,
    N.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = A.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        do throws(A.Failure) {
            try accumulated.serialize(output, into: &buffer)
        } catch {
            throw accumulatedFailure(error)
        }
        do throws(N.Failure) {
            try next.serialize((), into: &buffer)
        } catch {
            throw nextFailure(error)
        }
    }
}

extension Skip::Skip.Parser: Coder.`Protocol`
where
    Kept: ~Copyable & Escapable,
    Dropped == Void,
    A: Coder.`Protocol`,
    N: Coder.`Protocol`,
    A.Buffer == N.Buffer,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable,
    A.Output: ~Copyable & Escapable,
    A.Buffer: ~Copyable & ~Escapable,
    N.Buffer: ~Copyable & ~Escapable
{}
