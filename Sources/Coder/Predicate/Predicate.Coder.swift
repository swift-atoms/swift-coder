#if Predicate
    public import Predicate

    extension Predicate where T: ~Copyable & Escapable {
        public struct Coder<Upstream: Coding & ~Copyable>: Coding, ~Copyable
        where
            Upstream.Output == T, Upstream.Output: ~Copyable & Escapable,
            Upstream.Input: ~Copyable & ~Escapable, Upstream.Buffer: ~Copyable & ~Escapable
        {
            public typealias Input = Upstream.Input
            public typealias Output = Upstream.Output
            public typealias Buffer = Upstream.Buffer
            public typealias Failure = Upstream.Failure
            public let predicate: Predicate<T>
            public let upstream: Upstream
            public let failure: Failure
            public init(_ predicate: Predicate<T>, _ upstream: consuming Upstream, failure: Failure) {
                self.predicate = predicate
                self.upstream = upstream
                self.failure = failure
            }
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let value = try upstream.parse(&input)
                guard predicate(value) else { throw failure }
                return value
            }
            public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                guard predicate(output) else { throw failure }
                try upstream.serialize(output, into: &buffer)
            }
        }
    }
    extension Predicate.Coder: Copyable
    where
        T: ~Copyable,
        Upstream: Coding<Upstream.Input, Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
        Upstream.Input: ~Copyable & ~Escapable, Upstream.Output: ~Copyable,
        Upstream.Buffer: ~Copyable & ~Escapable
    {}

    extension Coding
    where
        Self: ~Copyable, Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable,
        Buffer: ~Copyable & ~Escapable
    {
        public consuming func filter(_ predicate: Predicate<Output>, failure: Failure)
            -> Predicate<Output>.Coder<Self>
        {
            .init(predicate, self, failure: failure)
        }
    }
#endif
