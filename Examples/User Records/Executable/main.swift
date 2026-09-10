import User_Records_Model

#if Pair && Skip && Map && Repetition
    let coder = User.Coder()
    var input: Substring = "Élodie van Dijk,0042\nremaining"
    let user = try coder.parse(&input)
    var canonical = ""
    try coder.serialize(user, into: &canonical)
    let decoded = try coder.whole(Substring(canonical))
    precondition(decoded == user)
    print("Parsed: \(user.name), age \(user.age)")
    print("Canonical: \(canonical.debugDescription)")
    print("Remainder: \(input.debugDescription)")
    var rejected: Substring = "Alice,30\nBob,not-an-age\nCarol,25\n"
    let batch = try records(&rejected)
    precondition(batch.count == 1 && rejected == "Bob,not-an-age\nCarol,25\n")
    print("Rejected batch: \(batch.count) record; remainder \(rejected.debugDescription)")
    var fatal: Substring = "Alice,30\nBob,999\nCarol,25\n"
    do {
        _ = try records(&fatal)
        preconditionFailure("Invalid age accepted")
    } catch {
        precondition(fatal == "Carol,25\n")
        print("Fatal: \(error); remainder \(fatal.debugDescription)")
    }
#else
    print("Enable Pair, Skip, Map, Repetition traits to run User Records.")
#endif
