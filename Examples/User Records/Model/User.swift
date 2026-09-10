@_exported public import Coder

public struct User: Equatable, Sendable {
    public let name: String
    public let age: Int
    public init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

public enum RecordFailure: Error, Equatable {
    case rejected
    case invalidAge(String)
    case invalidName
    case trailingInput
    case repetition
}

#if Pair && Skip && Map
    extension User {
        public struct Coder: Coding {
            public init() {}
            @Coder::Builder<Substring, String>
            public var body: some Coding<Substring, User, String, RecordFailure> {
                Coder::Coder(
                    { (fields: consuming Pair<String, String>) throws(RecordFailure) -> User in
                        guard let age = Int(fields.second), (0...130).contains(age) else {
                            throw .invalidAge(fields.second)
                        }
                        return User(name: fields.first, age: age)
                    },
                    from: { (user: borrowing User) throws(RecordFailure) -> Pair<String, String> in
                        guard (0...130).contains(user.age) else { throw .invalidAge(String(user.age)) }
                        guard !user.name.isEmpty, user.name.allSatisfy({ $0.isLetter || $0 == " " }) else {
                            throw .invalidName
                        }
                        return Pair(user.name, String(user.age))
                    }
                ) {
                    text { $0.isLetter || $0 == " " }
                    literal(",")
                    text { $0 >= "0" && $0 <= "9" }
                    literal("\n")
                }
            }

            public func whole(_ input: Substring) throws(RecordFailure) -> User {
                try parseAll(input, or: .trailingInput)
            }
        }
    }

    private func literal(_ text: String) -> Coder<Substring, Void, String, RecordFailure> {
        Coder(
            parse: { input throws(RecordFailure) in
                guard input.hasPrefix(text) else { throw .rejected }
                input.removeFirst(text.count)
            }, serialize: { _, buffer throws(RecordFailure) in buffer.append(contentsOf: text) })
    }

    private func text(while accepts: @escaping (Character) -> Bool) -> Coder<
        Substring, String, String, RecordFailure
    > {
        Coder(
            parse: { input throws(RecordFailure) in
                let token = input.prefix(while: accepts)
                guard !token.isEmpty else { throw .rejected }
                input.removeFirst(token.count)
                return String(token)
            },
            serialize: { output, buffer throws(RecordFailure) in
                guard !output.isEmpty, output.allSatisfy(accepts) else { throw .rejected }
                buffer.append(contentsOf: output)
            })
    }

    #if Repetition
        public struct UserRecords: Coding {
            public init() {}
            public var body: some Coding<Substring, [User], String, RecordFailure> {
                return Repetition((0...), operation: User.Coder()).coder(
                    rejected: { $0 == .rejected }, failure: { _ in .repetition }
                )
            }
        }
        public func records(_ input: inout Substring) throws(RecordFailure) -> [User] {
            try UserRecords().parse(&input)
        }
    #endif
#endif
