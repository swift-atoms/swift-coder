public import Cursor_Parser_Many
public import Parser
public import Serializer

extension Parser.Many.Separated: @retroactive Serializer.`Protocol`
where
    Element: Serializer.`Protocol`,
    Separator: Serializer.`Protocol`,
    Separator.Output == Void,
    Element.Buffer == Separator.Buffer
{

    public typealias Buffer = Element.Buffer

    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    @inlinable
    public func serialize(
        _ output: [Element.Output],
        into buffer: inout Buffer
    ) throws(Parser.Many<Input, Element>.Error) {
        if output.count < minimum {
            throw .countTooLow(expected: minimum, got: output.count)
        }
        if maximum < .max, output.count > maximum {
            throw .countTooHigh(expected: maximum, got: output.count)
        }

        var isFirst = true
        for item in output {
            if !isFirst {
                do throws(Separator.Failure) {
                    try separator.serialize((), into: &buffer)
                } catch {
                    break
                }
            }
            do throws(Element.Failure) {
                try element.serialize(item, into: &buffer)
            } catch {
                break
            }
            isFirst = false
        }
    }
}
