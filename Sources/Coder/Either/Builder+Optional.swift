#if Either
    extension Builder where Input: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
        @inlinable public static func buildOptional<C: Coding>(_ coder: C?) -> Swift.Optional<C>.Coder
        where
            C.Input == Input, C.Buffer == Buffer, C.Input: ~Copyable & ~Escapable,
            C.Output: ~Copyable & Escapable, C.Buffer: ~Copyable & ~Escapable
        { .init(coder) }
    }
#endif
