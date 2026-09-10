import Derived_Grammars
import Prism_Derivation
import Testing

@Test
func `derived user conversion round trips through safe pair storage`() throws {
  let coder = User.Coder()
  var input: Substring = "Élodie van Dijk,0042\nremaining"
  let user = try coder.prefix(&input)
  var output: Substring = ""
  try coder.write(user, into: &output)

  #expect(user == .value(name: "Élodie van Dijk", age: 42))
  #expect(input == "remaining")
  #expect(output == "Élodie van Dijk,42\n")
  #expect(try coder.whole(Substring(output)) == user)
}

@Test
func `derived user conversion rejects unsupported values and trailing input`() {
  let coder = User.Coder()

  #expect(throws: GrammarFailure.trailingInput) {
    try coder.whole("Alice,30\nextra")
  }
  #expect(throws: GrammarFailure.invalidAge("131")) {
    var output: Substring = ""
    try coder.write(.value(name: "Alice", age: 131), into: &output)
  }
  #expect(throws: GrammarFailure.invalidName) {
    var output: Substring = ""
    try coder.write(.value(name: "A,B", age: 30), into: &output)
  }
}

@Test
func `age validation follows the complete record grammar`() {
  var invalidAge: Substring = "Alice,999\nnext"
  #expect(throws: GrammarFailure.invalidAge("999")) {
    try User.Coder().prefix(&invalidAge)
  }
  #expect(invalidAge == "next")

  var missingLF: Substring = "Alice,999x"
  #expect(throws: GrammarFailure.rejected) {
    try User.Coder().prefix(&missingLF)
  }
  #expect(missingLF == "x")
}

@Test
func `derived prism selects explicit tagged branches in both directions`() throws {
  let coder = Node.Coder()

  #expect(try coder.whole("leaf(0042)") == .leaf(42))
  #expect(try coder.whole("pair(7,9)") == .pair(7, 9))

  var leaf: Substring = ""
  try coder.write(.leaf(42), into: &leaf)
  var pair: Substring = ""
  try coder.write(.pair(7, 9), into: &pair)

  #expect(leaf == "leaf(42)")
  #expect(pair == "pair(7,9)")
}

@Test
func `derived prism supports explicit dynamic member extraction key paths`() {
  func apply(_ node: Node, extract: (Node) -> Int?) -> Int? {
    extract(node)
  }

  #expect(apply(.leaf(42), extract: \.leaf) == 42)
  #expect(apply(.pair(1, 2), extract: \.leaf) == nil)
  #expect(extractedLeaf(.leaf(7)) == 7)
}

@Test
func `recognized malformed branch is fatal and unknown tag is rejected`() {
  #expect(throws: GrammarFailure.invalidInteger("x")) {
    try Node.Coder().whole("leaf(x)")
  }
  #expect(throws: GrammarFailure.rejected) {
    try Node.Coder().whole("other(42)")
  }

  var malformed: Substring = "leaf(42]tail"
  #expect(throws: GrammarFailure.malformed) {
    try Node.Coder().prefix(&malformed)
  }
  #expect(malformed == "]tail")
}
