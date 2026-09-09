public import Parser
public import Serializer

extension Coder {

    public struct Map<Upstream: Coder.`Protocol`, Output: ~Copyable>
    where
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & Escapable,
        Upstream.Buffer: ~Copyable & ~Escapable
    {
        public let upstream: Upstream

        public let forward: (consuming Upstream.Output) -> Output

        public let backward: (borrowing Output) -> Upstream.Output

        @inlinable
        public init(
            upstream: Upstream,
            forward: @escaping (consuming Upstream.Output) -> Output,
            backward: @escaping (borrowing Output) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.forward = forward
            self.backward = backward
        }
    }
}

extension Coder.Map: Parsing
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{

    public typealias Input = Upstream.Input

    public typealias Failure = Upstream.Failure

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        forward(try upstream.parse(&input))
    }
}

extension Coder.Map: Serializer.`Protocol`
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = Upstream.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        try upstream.serialize(backward(output), into: &buffer)
    }
}

extension Coder.Map: Coder.`Protocol`
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{}

extension Coder.`Protocol`
where
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & Escapable,
    Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public func map<New: ~Copyable>(
        to forward: @escaping (consuming Output) -> New,
        from backward: @escaping (borrowing New) -> Output
    ) -> Coder.Map<Self, New> {
        .init(upstream: self, forward: forward, backward: backward)
    }
}
