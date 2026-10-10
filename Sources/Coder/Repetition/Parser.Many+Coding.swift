#if Repetition
public import Coder_Core
public import Parser
public import Serializer
public import Checkpoint

extension Parser::Many: @retroactive Serializing, Coding
where Source: Restorable & ~Copyable & ~Escapable, Element: Coding,
      Element.Input: ~Copyable & ~Escapable, Element.Buffer: ~Copyable & ~Escapable {

    public typealias Buffer = Element.Buffer
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Error) {
        guard minimum >= 0, maximum >= minimum else { throw .invalidBounds }
        guard output.count >= minimum else { throw .countTooLow(expected: minimum, got: output.count) }
        guard output.count <= maximum else { throw .countTooHigh(expected: maximum, got: output.count) }
        for index in output.indices {
            do throws(Element.Failure) { try element.serialize(output[index], into: &buffer) }
            catch { throw .element(error) }
        }
    }
}

extension Parser::Many.Separated: @retroactive Serializing, Coding
where Source: Restorable & ~Copyable & ~Escapable,
      Element: Coding, Separator: Coding, Separator.Output == Void,
      Element.Input: ~Copyable & ~Escapable, Separator.Input: ~Copyable & ~Escapable,
      Element.Buffer == Separator.Buffer, Element.Buffer: ~Copyable & ~Escapable,
      Separator.Buffer: ~Copyable & ~Escapable {

    public typealias Buffer = Element.Buffer
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Error) {
        guard minimum >= 0, maximum >= minimum else { throw .invalidBounds }
        guard output.count >= minimum else { throw .countTooLow(expected: minimum, got: output.count) }
        guard output.count <= maximum else { throw .countTooHigh(expected: maximum, got: output.count) }
        for index in output.indices {
            if index != output.startIndex {
                do throws(Separator.Failure) { try separator.serialize((), into: &buffer) }
                catch { throw .separator(error) }
            }
            do throws(Element.Failure) { try element.serialize(output[index], into: &buffer) }
            catch { throw .element(error) }
        }
    }
}
#endif
