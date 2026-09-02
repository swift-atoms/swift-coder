public import Coder
public import Parser
public import Parser_Standard_Library_Integration
import Serializer

extension Swift.String: Coder.`Protocol`, Parser.Bidirectional {

    public typealias Body = Never
}
