public import Coder
public import Parser
import Serializer_Core

extension Swift.String: Coder.`Protocol`, Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.Always: Coder.`Protocol`, Parser.Bidirectional where Output == Void {

    public typealias Body = Never
}

extension Parser.Take.Two: Coder.`Protocol`
where P0: Coder.`Protocol`, P1: Coder.`Protocol`, P0.Buffer == P1.Buffer {

    public typealias Body = Never
}

extension Parser.Take.Two: Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

extension Parser.Skip.First: Coder.`Protocol`
where P0: Coder.`Protocol`, P1: Coder.`Protocol`, P0.Buffer == P1.Buffer {

    public typealias Body = Never
}

extension Parser.Skip.First: Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

extension Parser.Skip.Second: Coder.`Protocol`
where P0: Coder.`Protocol`, P1: Coder.`Protocol`, P0.Buffer == P1.Buffer {

    public typealias Body = Never
}

extension Parser.Skip.Second: Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

extension Parser.Take.Sequence: Coder.`Protocol` where Body: Coder.`Protocol` {

    public typealias Body = Never
}

extension Parser.Take.Sequence: Parser.Bidirectional where Body: Parser.Bidirectional {}

extension Parser.OneOf.Two: Coder.`Protocol`
where P0: Coder.`Protocol`, P1: Coder.`Protocol`, P0.Buffer == P1.Buffer {

    public typealias Body = Never
}

extension Parser.OneOf.Two: Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

extension Parser.OneOf.Sequence: Coder.`Protocol` where Body: Coder.`Protocol` {

    public typealias Body = Never
}

extension Parser.OneOf.Sequence: Parser.Bidirectional where Body: Parser.Bidirectional {}

extension Parser.Converted: Coder.`Protocol` where Upstream: Coder.`Protocol` {

    public typealias Body = Never
}

extension Parser.Converted: Parser.Bidirectional where Upstream: Parser.Bidirectional {}

extension Parser.Error.Map: Coder.`Protocol` where Upstream: Coder.`Protocol` {

    public typealias Body = Never
}

extension Parser.Error.Map: Parser.Bidirectional where Upstream: Parser.Bidirectional {}
