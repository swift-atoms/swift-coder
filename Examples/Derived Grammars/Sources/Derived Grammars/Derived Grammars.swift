public import Coder
public import Isomorphism_Derivation
public import Prism_Derivation

public enum GrammarFailure: Error, Equatable {
  case rejected
  case invalidName
  case invalidAge(String)
  case invalidInteger(String)
  case malformed
  case trailingInput
}

@Isomorphism
public struct User: Equatable, Sendable {
  public let name: String
  public let age: Int

  public static func value(name: String, age: Int) -> Self {
    Self(name: name, age: age)
  }
}

extension User {
  public struct Coder: Coding {
    public init() {}

    @Coder::Builder<Substring, Substring>
    public var body: some Coding<Substring, User, Substring, GrammarFailure> {
      Coder::Coder {
        nameToken()
        literal(",")
        digitsToken()
        literal("\n")
      }
      .map(
        to: { fields throws(GrammarFailure) in
          guard let age = Int(fields.second), (0...130).contains(age) else {
            throw .invalidAge(fields.second)
          }
          return Pair(fields.first, age)
        },
        from: { fields throws(GrammarFailure) in
          guard (0...130).contains(fields.second) else {
            throw .invalidAge(String(fields.second))
          }
          return Pair(fields.first, String(fields.second))
        }
      )
      .map(
        pairTuple(String.self, Int.self)
          .appending(User.isomorphisms.memberwise.reversed)
      )
    }

    public func whole(_ input: Substring) throws(GrammarFailure) -> User {
      var remaining = input
      let value = try parse(&remaining)
      guard remaining.isEmpty else { throw .trailingInput }
      return value
    }

    public func prefix(_ input: inout Substring) throws(GrammarFailure) -> User {
      try parse(&input)
    }

    public func write(
      _ value: borrowing User,
      into buffer: inout Substring
    ) throws(GrammarFailure) {
      try serialize(value, into: &buffer)
    }
  }
}

@Prisms
@dynamicMemberLookup
public enum Node: Equatable, Sendable {
  case leaf(Int)
  case pair(Int, Int)
}

extension Node {
  public struct Coder: Coding {
    public init() {}

    @Coder::Builder<Substring, Substring>
    public var body: some Coding<Substring, Node, Substring, GrammarFailure> {
      Coder::OneOf.Sequence(absent: .rejected) {
        Coder::Case(Node.prisms.leaf, absent: .rejected) {
          literal("leaf(")
          Coder::Coder {
            nodeInteger()
            literal(")")
          }
          .mapFailure(syntaxFailure)
        }
        Coder::Case(Node.prisms.pair, absent: .rejected) {
          literal("pair(")
          Coder::Coder {
            nodeInteger()
            literal(",")
            nodeInteger()
            literal(")")
          }
          .map(pairTuple(Int.self, Int.self))
          .mapFailure(syntaxFailure)
        }
      }
    }

    public func whole(_ input: Substring) throws(GrammarFailure) -> Node {
      var remaining = input
      let value = try parse(&remaining)
      guard remaining.isEmpty else { throw .trailingInput }
      return value
    }

    public func write(
      _ value: borrowing Node,
      into buffer: inout Substring
    ) throws(GrammarFailure) {
      try serialize(value, into: &buffer)
    }

    public func prefix(_ input: inout Substring) throws(GrammarFailure) -> Node {
      try parse(&input)
    }
  }
}

public func extractedLeaf(_ node: Node) -> Int? {
  func apply(_ node: Node, extract: (Node) -> Int?) -> Int? {
    extract(node)
  }
  return apply(node, extract: \.leaf)
}

private func pairTuple<First: Copyable, Second: Copyable>(
  _: First.Type,
  _: Second.Type
)
  -> Optic<
    Pair<First, Second>,
    Pair<First, Second>,
    (First, Second),
    (First, Second)
  >.Isomorphism
{
  .init(
    forward: { $0.tuple },
    backward: { Pair($0) }
  )
}

private func literal(_ spelling: String) -> Coder<Substring, Void, Substring, GrammarFailure> {
  Coder(
    parse: { input throws(GrammarFailure) in
      guard input.hasPrefix(spelling) else { throw .rejected }
      input.removeFirst(spelling.count)
    },
    serialize: { _, buffer throws(GrammarFailure) in
      buffer.append(contentsOf: spelling)
    }
  )
}

private func nameToken() -> Coder<Substring, String, Substring, GrammarFailure> {
  Coder(
    parse: { input throws(GrammarFailure) in
      let token = input.prefix { $0.isLetter || $0 == " " }
      guard !token.isEmpty else { throw .rejected }
      input.removeFirst(token.count)
      return String(token)
    },
    serialize: { value, buffer throws(GrammarFailure) in
      guard !value.isEmpty, value.allSatisfy({ $0.isLetter || $0 == " " }) else {
        throw .invalidName
      }
      buffer.append(contentsOf: value)
    }
  )
}

private func digitsToken() -> Coder<Substring, String, Substring, GrammarFailure> {
  Coder(
    parse: { input throws(GrammarFailure) in
      let digits = input.prefix { $0 >= "0" && $0 <= "9" }
      guard !digits.isEmpty else { throw .rejected }
      input.removeFirst(digits.count)
      return String(digits)
    },
    serialize: { value, buffer throws(GrammarFailure) in
      guard !value.isEmpty, value.allSatisfy({ $0 >= "0" && $0 <= "9" }) else {
        throw .invalidAge(value)
      }
      buffer.append(contentsOf: value)
    }
  )
}

private func syntaxFailure(_ failure: GrammarFailure) -> GrammarFailure {
  failure == .rejected ? .malformed : failure
}

private func nodeInteger() -> Coder<Substring, Int, Substring, GrammarFailure> {
  Coder(
    parse: { input throws(GrammarFailure) in
      let digits = input.prefix { $0 >= "0" && $0 <= "9" }
      guard !digits.isEmpty else { throw .invalidInteger(String(input.prefix(1))) }
      input.removeFirst(digits.count)
      guard let value = Int(digits) else { throw .invalidInteger(String(digits)) }
      return value
    },
    serialize: { value, buffer throws(GrammarFailure) in
      guard value >= 0 else { throw .invalidInteger(String(value)) }
      buffer.append(contentsOf: String(value))
    }
  )
}
