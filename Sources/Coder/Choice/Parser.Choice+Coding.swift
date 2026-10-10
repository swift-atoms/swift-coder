#if Choice
public import Parser
public import Serializer
public import Checkpoint

extension Parser::OneOf.Two: @retroactive Serializing, Coding
where P0: Coding, P1: Coding, P0.Buffer == P1.Buffer,
      P0.Buffer: RangeReplaceableCollection,
      P0.Input: Restorable & ~Copyable & ~Escapable, P1.Input: ~Copyable & ~Escapable,
      P0.Output: ~Copyable & Escapable, P1.Output: ~Copyable & Escapable {

    public typealias Buffer = P0.Buffer

    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Error) {
        var staged = Buffer()
        let first: P0.Failure
        do throws(P0.Failure) {
            try p0.serialize(output, into: &staged)
            buffer.append(contentsOf: staged)
            return
        } catch {
            guard serializationRejectFirst(error) else {
                buffer.append(contentsOf: staged)
                throw .first(error)
            }
            first = error
        }
        staged = Buffer()
        do throws(P1.Failure) {
            try p1.serialize(output, into: &staged)
            buffer.append(contentsOf: staged)
        } catch {
            guard serializationRejectSecond(error) else {
                buffer.append(contentsOf: staged)
                throw .second(error)
            }
            throw .rejected(first: first, second: error)
        }
    }
}

extension Parser::Optionally: @retroactive Serializing, Coding
where Wrapped: Coding, Wrapped.Input: Restorable & ~Copyable & ~Escapable,
      Wrapped.Output: ~Copyable & Escapable, Wrapped.Buffer: ~Copyable & ~Escapable {

    public typealias Buffer = Wrapped.Buffer
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        switch output {
        case .some(let value): try wrapped.serialize(value, into: &buffer)
        case .none: return
        }
    }
}
#endif
