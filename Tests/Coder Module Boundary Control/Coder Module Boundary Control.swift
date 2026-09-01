public import Coder
public import Coder_Primitive

extension Coder {

    public struct Boundary {

        public init() {}
    }
}

extension Coder.Boundary: Coder_Primitive::Coder.`Protocol` {

    public typealias Input = Void

    public typealias Output = Void

    public typealias Buffer = Void

    public typealias Failure = Never

    public typealias Body = Never

    public func parse(_ input: inout Void) {}

    public func serialize(_ output: Void, into buffer: inout Void) {}
}

extension Coder.Boundary {

    public static func exercise() {
        var input: Void = ()
        var buffer: Void = ()

        let leaf = Self()
        leaf.parse(&input)
        leaf.serialize((), into: &buffer)

        let witness = Coder.Witness<Void, Void, Void, Never>(
            parse: { _ in () },
            serialize: { _, _ in }
        )
        witness.parse(&input)
        witness.serialize((), into: &buffer)
    }
}
