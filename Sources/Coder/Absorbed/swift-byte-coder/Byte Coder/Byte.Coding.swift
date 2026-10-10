#if Byte
public import Coder_Core
public import Byte

extension Byte {

    public typealias Coding<Output: ~Copyable & ~Escapable, Failure: Swift.Error> =
    Coder::Coding<
        ArraySlice<Byte>,
        Output,
        [Byte],
        Failure
    >
}
#endif
