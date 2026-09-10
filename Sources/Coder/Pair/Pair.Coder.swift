#if Pair
    public import Either
    public import Pair
    public import Parser
    public import Serializer

    extension Pair::Pair
    where
        First: Coding & ~Copyable,
        Second: Coding & ~Copyable,
        First.Input == Second.Input,
        First.Buffer == Second.Buffer,
        First.Buffer: ~Copyable & ~Escapable,
        Second.Buffer: ~Copyable & ~Escapable,
        First.Input: ~Copyable & ~Escapable,
        Second.Input: ~Copyable & ~Escapable,
        First.Output: ~Copyable & Escapable,
        Second.Output: ~Copyable & Escapable
    {

        public struct Coder<Failure: Swift.Error>: Coding, ~Copyable {

            public typealias Buffer = First.Buffer

            public typealias Input = First.Input

            public typealias Output = Pair::Pair<First.Output, Second.Output>

            public let first: First

            public let second: Second

            public let firstFailure: (First.Failure) -> Failure

            public let secondFailure: (Second.Failure) -> Failure

            @inlinable
            public init(
                _ first: consuming First,
                _ second: consuming Second,
                _ firstFailure: @escaping (First.Failure) -> Failure,
                _ secondFailure: @escaping (Second.Failure) -> Failure
            ) {
                self.first = first
                self.second = second
                self.firstFailure = firstFailure
                self.secondFailure = secondFailure
            }

            @inlinable
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let firstOutput: First.Output
                do throws(First.Failure) {
                    firstOutput = try first.parse(&input)
                } catch {
                    throw firstFailure(error)
                }
                let secondOutput: Second.Output
                do throws(Second.Failure) {
                    secondOutput = try second.parse(&input)
                } catch {
                    throw secondFailure(error)
                }
                return Output(firstOutput, secondOutput)
            }

            @inlinable public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                do throws(First.Failure) { try first.serialize(output.first, into: &buffer) } catch {
                    throw firstFailure(error)
                }
                do throws(Second.Failure) { try second.serialize(output.second, into: &buffer) } catch {
                    throw secondFailure(error)
                }
            }
        }

        @inlinable
        public consuming func coder()
            -> Pair::Pair<First, Second>.Coder<Either<First.Failure, Second.Failure>>
        {
            .init(first, second, { .left($0) }, { .right($0) })
        }

        @inlinable
        public consuming func coder() -> Pair::Pair<First, Second>.Coder<First.Failure>
        where First.Failure == Second.Failure {
            .init(first, second, { $0 }, { $0 })
        }
        @inlinable public consuming func coder() -> Pair::Pair<First, Second>.Coder<Second.Failure>
        where First.Failure == Never { .init(first, second, { $0 }, { $0 }) }

        @inlinable public consuming func coder() -> Pair::Pair<First, Second>.Coder<First.Failure>
        where Second.Failure == Never { .init(first, second, { $0 }, { $0 }) }

        @inlinable public consuming func coder() -> Pair::Pair<First, Second>.Coder<Never>
        where First.Failure == Never, Second.Failure == Never { .init(first, second, { $0 }, { $0 }) }

    }

    extension Pair::Pair.Coder: Copyable
    where
        First.Buffer: ~Copyable & ~Escapable,
        Second.Buffer: ~Copyable & ~Escapable,
        First: Coding<First.Input, First.Output, First.Buffer, First.Failure> & Copyable,
        Second: Coding<Second.Input, Second.Output, Second.Buffer, Second.Failure> & Copyable,
        First.Input: ~Copyable & ~Escapable,
        Second.Input: ~Copyable & ~Escapable,
        First.Output: ~Copyable & Escapable,
        Second.Output: ~Copyable & Escapable
    {}

#endif
