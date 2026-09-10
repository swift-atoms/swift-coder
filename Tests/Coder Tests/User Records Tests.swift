import Coder
import Testing
import User_Records_Model

#if Pair && Skip && Map && Repetition
    @Suite struct UserRecordsTests {
        @Test func unicodeNamesAndCanonicalAges() throws {
            for (wire, expected) in [
                ("Élodie,0042\n", User(name: "Élodie", age: 42)), ("李 明,000\n", User(name: "李 明", age: 0)),
                ("Zoë,130\n", User(name: "Zoë", age: 130)),
            ] {
                let coder = User.Coder()
                let user = try coder.whole(Substring(wire))
                #expect(user == expected)
                var encoded = ""
                try coder.serialize(user, into: &encoded)
                #expect(encoded == "\(user.name),\(user.age)\n")
                #expect(try coder.whole(Substring(encoded)) == user)
            }
        }
        @Test func prefixAndWhole() throws {
            var input: Substring = "Alice,30\nCarol,25\n"
            #expect(try User.Coder().parse(&input) == User(name: "Alice", age: 30))
            #expect(input == "Carol,25\n")
            #expect(throws: RecordFailure.trailingInput) { try User.Coder().whole("Alice,30\nextra") }
        }
        @Test func delimitersAndLexicalRules() {
            for wire in [
                "Alice30\n", "Alice,30", "Alice,30\r\n", ",30\n", "Alice,-1\n", "Alice,٣٠\n", "Alice,\n",
                "Alice1,30\n",
            ] {
                #expect(throws: RecordFailure.rejected) { try User.Coder().whole(Substring(wire)) }
            }
        }
        @Test func invalidSerializationValidatesBeforeWriting() {
            for user in [
                User(name: "Alice", age: -1), User(name: "Alice", age: 131), User(name: "", age: 20),
                User(name: "A,B", age: 20),
            ] {
                var output = "prefix:"
                #expect(throws: RecordFailure.self) { try User.Coder().serialize(user, into: &output) }
                #expect(output == "prefix:")
            }
        }
        @Test func batchRejectionRestoresCompleteAttempt() throws {
            var input: Substring = "Alice,30\nBob,not-an-age\nCarol,25\n"
            #expect(try records(&input) == [User(name: "Alice", age: 30)])
            #expect(input == "Bob,not-an-age\nCarol,25\n")
        }
        @Test func invalidAgeIsFatalAfterCompleteRecord() {
            for age in ["131", String(repeating: "9", count: 100)] {
                var input = Substring("Alice,30\nBob,\(age)\nCarol,25\n")
                #expect(throws: RecordFailure.invalidAge(age)) { try records(&input) }
                #expect(input == "Carol,25\n")
            }
        }
    }
#endif
