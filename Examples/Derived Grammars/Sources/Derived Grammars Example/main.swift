import Derived_Grammars

let userCoder = User.Coder()
var userInput: Substring = "Élodie van Dijk,0042\nremaining"
let user = try userCoder.prefix(&userInput)
var canonicalUser: Substring = ""
try userCoder.write(user, into: &canonicalUser)

precondition(user == .value(name: "Élodie van Dijk", age: 42))
precondition(canonicalUser == "Élodie van Dijk,42\n")
precondition(userInput == "remaining")

let nodeCoder = Node.Coder()
let node = try nodeCoder.whole("leaf(0042)")
var canonicalNode: Substring = ""
try nodeCoder.write(.pair(7, 9), into: &canonicalNode)

precondition(extractedLeaf(node) == 42)
precondition(canonicalNode == "pair(7,9)")

print("User: \(canonicalUser.debugDescription), remainder: \(userInput.debugDescription)")
print("Node leaf: \(String(describing: extractedLeaf(node))), pair: \(canonicalNode)")
