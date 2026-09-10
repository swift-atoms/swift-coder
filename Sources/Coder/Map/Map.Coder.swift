#if Map
    public import Map

    extension Map where Source: ~Copyable & Escapable, Target: ~Copyable & Escapable {
        public struct Coder<Upstream: Coding & ~Copyable>: Coding, ~Copyable
        where
            Upstream.Output == Source, Upstream.Failure == Failure,
            Upstream.Input: ~Copyable & ~Escapable, Upstream.Output: ~Copyable,
            Upstream.Buffer: ~Copyable & ~Escapable
        {
            public typealias Input = Upstream.Input
            public typealias Output = Target
            public typealias Buffer = Upstream.Buffer
            public typealias Failure = Upstream.Failure
            public let upstream: Upstream
            public let forward: (consuming Upstream.Output) throws(Failure) -> Output
            public let backward: (borrowing Output) throws(Failure) -> Upstream.Output
            @inlinable public init(
                upstream: consuming Upstream,
                forward: @escaping (consuming Upstream.Output) throws(Failure) -> Output,
                backward: @escaping (borrowing Output) throws(Failure) -> Upstream.Output
            ) {
                self.upstream = upstream
                self.forward = forward
                self.backward = backward
            }
            @inlinable public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                try forward(upstream.parse(&input))
            }
            @inlinable public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                try upstream.serialize(backward(output), into: &buffer)
            }
        }
    }
    extension Map.Coder: Copyable
    where
        Source: ~Copyable, Target: ~Copyable,
        Upstream: Coding<Upstream.Input, Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable, Upstream.Buffer: ~Copyable & ~Escapable
    {}
#endif
