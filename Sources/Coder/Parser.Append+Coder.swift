public import Parser
public import Parser_Skip
public import Serializer

extension Parser.Append: Serializer.`Protocol`
where
    A: Serializer.`Protocol`,
    N: Serializer.`Protocol`,
    A.Buffer == N.Buffer,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable,
    A.Buffer: ~Copyable & ~Escapable,
    N.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = A.Buffer

    public static var splitsByLayout: Bool {
        MemoryLayout<(repeat each O, N.Output)>.size == MemoryLayout<((repeat each O), N.Output)>.size
            && MemoryLayout<(repeat each O, N.Output)>.alignment == MemoryLayout<((repeat each O), N.Output)>.alignment
            && MemoryLayout<(repeat each O, N.Output)>.stride == MemoryLayout<((repeat each O), N.Output)>.stride
    }

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        guard Self.splitsByLayout else {
            return
        }
        let (head, last) = unsafe unsafeBitCast(copy output, to: ((repeat each O), N.Output).self)
        do throws(A.Failure) {
            try accumulated.serialize(head, into: &buffer)
        } catch {
            throw accumulatedFailure(error)
        }
        do throws(N.Failure) {
            try next.serialize(last, into: &buffer)
        } catch {
            throw nextFailure(error)
        }
    }
}

extension Parser.Append: Coder.`Protocol`
where
    A: Coder.`Protocol`,
    N: Coder.`Protocol`,
    A.Buffer == N.Buffer,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable,
    A.Buffer: ~Copyable & ~Escapable,
    N.Buffer: ~Copyable & ~Escapable
{}
