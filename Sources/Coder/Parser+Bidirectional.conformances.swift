public import Parser
public import Parser_Error
public import Parser_Skip
public import Parser_Take
public import Serializer

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

extension Parser.Error.Map: Coder.`Protocol` where Upstream: Coder.`Protocol` {

    public typealias Body = Never
}

extension Parser.Error.Map: Parser.Bidirectional where Upstream: Parser.Bidirectional {}
