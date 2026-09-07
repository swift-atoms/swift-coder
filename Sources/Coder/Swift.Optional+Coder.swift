public import Either
public import Parser
public import Serializer

extension Swift.Optional
where
    Wrapped: Coding,
    Wrapped.Input: ~Copyable & ~Escapable,
    Wrapped.Output: ~Copyable & Escapable,
    Wrapped.Buffer: ~Copyable & ~Escapable
{

    public struct Coder: Coder::Coder.`Protocol` {

        public enum Error: Swift.Error, Equatable {

            case missingValue

            case unexpectedValue
        }

        public typealias Input = Wrapped.Input

        public typealias Output = Wrapped.Output?

        public typealias Buffer = Wrapped.Buffer

        public typealias Failure = Either<Wrapped.Failure, Error>

        public let wrapped: Swift.Optional<Wrapped>

        @inlinable
        public init(_ wrapped: Swift.Optional<Wrapped>) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            guard let wrapped else {
                return nil
            }
            do throws(Wrapped.Failure) {
                return try wrapped.parse(&input)
            } catch {
                throw .left(error)
            }
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            guard let wrapped else {
                switch output {
                case .none:
                    return
                case .some:
                    throw .right(.unexpectedValue)
                }
            }
            switch output {
            case .some(let value):
                do throws(Wrapped.Failure) {
                    try wrapped.serialize(value, into: &buffer)
                } catch {
                    throw .left(error)
                }
            case .none:
                throw .right(.missingValue)
            }
        }
    }
}
