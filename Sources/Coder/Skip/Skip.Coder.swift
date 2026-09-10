#if Skip
    public import Skip

    extension Skip where Kept: ~Copyable, Dropped == Void {

        public struct Coder<A: Coding & ~Copyable, N: Coding & ~Copyable, Failure: Swift.Error>: Coding,
            ~Copyable
        where
            A.Input == N.Input, A.Buffer == N.Buffer, A.Output == Kept, N.Output == Void,
            A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable,
            A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable
        {
            public typealias Input = A.Input
            public typealias Output = A.Output
            public typealias Buffer = A.Buffer
            public let kept: A
            public let dropped: N
            public let leading: Bool
            public let keptFailure: (A.Failure) -> Failure
            public let droppedFailure: (N.Failure) -> Failure
            @inlinable public init(
                _ kept: consuming A, _ dropped: consuming N, leading: Bool = false,
                _ keptFailure: @escaping (A.Failure) -> Failure,
                _ droppedFailure: @escaping (N.Failure) -> Failure
            ) {
                self.kept = kept
                self.dropped = dropped
                self.leading = leading
                self.keptFailure = keptFailure
                self.droppedFailure = droppedFailure
            }
            @inlinable public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                if leading {
                    do throws(N.Failure) { try dropped.parse(&input) } catch { throw droppedFailure(error) }
                }
                let output: Output
                do throws(A.Failure) { output = try kept.parse(&input) } catch { throw keptFailure(error) }
                if !leading {
                    do throws(N.Failure) { try dropped.parse(&input) } catch { throw droppedFailure(error) }
                }
                return output
            }
            @inlinable public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer)
                throws(Failure)
            {
                if leading {
                    do throws(N.Failure) { try dropped.serialize((), into: &buffer) } catch {
                        throw droppedFailure(error)
                    }
                }
                do throws(A.Failure) { try kept.serialize(output, into: &buffer) } catch {
                    throw keptFailure(error)
                }
                if !leading {
                    do throws(N.Failure) { try dropped.serialize((), into: &buffer) } catch {
                        throw droppedFailure(error)
                    }
                }
            }
        }
    }
    extension Skip.Coder: Copyable
    where
        Kept: ~Copyable, Dropped == Void,
        A: Coding<A.Input, A.Output, A.Buffer, A.Failure> & Copyable,
        N: Coding<N.Input, N.Output, N.Buffer, N.Failure> & Copyable,
        A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable
    {}
#endif
