public import Parser

extension Coder {

    /// A tuple-specific codec. Its parser delegates to the general append adapter;
    /// serialization retains the tuple layout needed to recover both operands.
    public struct Append<A: Parsing & ~Copyable, N: Parsing & ~Copyable, Failure: Swift.Error, each O>: Parsing, ~Copyable
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O)
    {
        public typealias Input = A.Input
        public typealias Output = (repeat each O, N.Output)

        public let body: Append::Append<A.Output, N.Output, Output, Never>.Parser<A, N, Failure>

        @inlinable
        public init(
            _ accumulated: consuming A,
            _ next: consuming N,
            _ accumulatedFailure: @escaping (A.Failure) -> Failure,
            _ nextFailure: @escaping (N.Failure) -> Failure
        ) {
            self.body = .init(
                .init(), accumulated, next,
                accumulatedFailure: accumulatedFailure,
                nextFailure: nextFailure,
                appendFailure: { $0 }
            )
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try body.parse(&input)
        }
    }
}

extension Coder.Append: Copyable
where
    A: Parsing<A.Input, A.Output, A.Failure> & Copyable,
    N: Parsing<N.Input, N.Output, N.Failure> & Copyable,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable
{}
