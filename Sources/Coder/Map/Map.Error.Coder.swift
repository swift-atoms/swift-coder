#if Map
    public import Map

    extension Map.Error where Source: Swift.Error, Target: Swift.Error, Failure == Never {
        public struct Coder<Upstream: Coding & ~Copyable>: Coding, ~Copyable
        where
            Upstream.Failure == Source, Upstream.Input: ~Copyable & ~Escapable,
            Upstream.Output: ~Copyable & Escapable, Upstream.Buffer: ~Copyable & ~Escapable
        {
            public typealias Input = Upstream.Input
            public typealias Output = Upstream.Output
            public typealias Buffer = Upstream.Buffer
            public typealias Failure = Target
            public let upstream: Upstream
            public let transform: (Upstream.Failure) -> Failure
            @inlinable public init(
                _ upstream: consuming Upstream, _ transform: @escaping (Upstream.Failure) -> Failure
            ) {
                self.upstream = upstream
                self.transform = transform
            }
            @inlinable public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                do throws(Upstream.Failure) { return try upstream.parse(&input) } catch {
                    throw transform(error)
                }
            }
            @inlinable public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                do throws(Upstream.Failure) { try upstream.serialize(output, into: &buffer) } catch {
                    throw transform(error)
                }
            }
        }
    }
    extension Map.Error.Coder: Copyable
    where
        Source: Swift.Error, Target: Swift.Error, Failure == Never,
        Upstream: Coding<Upstream.Input, Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable, Upstream.Buffer: ~Copyable & ~Escapable
    {}
#endif
