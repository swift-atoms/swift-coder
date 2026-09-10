extension Coding
where
    Self: ~Copyable, Input: Swift.Collection, Output: ~Copyable & Escapable,
    Buffer: ~Copyable & ~Escapable
{

    public borrowing func parseAll(_ input: consuming Input, or failure: Failure) throws(Failure) -> Output {
        var cursor = input
        let output = try parse(&cursor)
        guard cursor.isEmpty else { throw failure }
        return output
    }
}
