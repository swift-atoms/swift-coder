#if Byte
extension Swift.String.Coder {

    public enum Error: Swift.Error, Equatable {
        case invalid
        case malformed
    }
}
#endif
