#if Either
    public import Either

    extension Either
    where
        Left: Coding & ~Copyable,
        Right: Coding & ~Copyable,
        Left.Input == Right.Input,
        Left.Buffer == Right.Buffer,
        Left.Buffer: ~Copyable & ~Escapable,
        Right.Buffer: ~Copyable & ~Escapable,
        Left.Output == Right.Output,
        Left.Input: ~Copyable & ~Escapable,
        Right.Input: ~Copyable & ~Escapable,
        Left.Output: ~Copyable & ~Escapable,
        Right.Output: ~Copyable & ~Escapable
    {
        public struct Coder: Coding, ~Copyable {
            public typealias Buffer = Left.Buffer
            public typealias Input = Left.Input
            public typealias Output = Left.Output
            public typealias Failure = Either<Left.Failure, Right.Failure>

            public let wrapped: Either<Left, Right>

            @inlinable
            public init(_ wrapped: consuming Either<Left, Right>) {
                self.wrapped = wrapped
            }

            @inlinable
            @_lifetime(borrow self, &input)
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                switch wrapped {
                case .left(let parser):
                    do throws(Left.Failure) {
                        return try parser.parse(&input)
                    } catch {
                        throw .left(error)
                    }
                case .right(let parser):
                    do throws(Right.Failure) {
                        return try parser.parse(&input)
                    } catch {
                        throw .right(error)
                    }
                }
            }
            @inlinable public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                switch wrapped {
                case .left(let coder):
                    do throws(Left.Failure) { try coder.serialize(output, into: &buffer) } catch {
                        throw .left(error)
                    }
                case .right(let coder):
                    do throws(Right.Failure) { try coder.serialize(output, into: &buffer) } catch {
                        throw .right(error)
                    }
                }
            }
        }

        @inlinable
        public consuming func coder() -> Coder {
            .init(self)
        }
    }
    extension Either.Coder: Copyable
    where
        Left: Coding<Left.Input, Left.Output, Left.Buffer, Left.Failure> & Copyable,
        Right: Coding<Right.Input, Right.Output, Right.Buffer, Right.Failure> & Copyable,
        Left.Buffer: ~Copyable & ~Escapable, Right.Buffer: ~Copyable & ~Escapable,
        Left.Input: ~Copyable & ~Escapable, Right.Input: ~Copyable & ~Escapable,
        Left.Output: ~Copyable & ~Escapable, Right.Output: ~Copyable & ~Escapable
    {}
#endif
