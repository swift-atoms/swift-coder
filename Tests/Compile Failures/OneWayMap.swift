import Coder

func requireCoding<C: Coding>(_ value: C) {}
let leaf = Coder<Substring, Int, String, Never>(
    parse: { _ in 1 }, serialize: { value, buffer in buffer += String(value) })
requireCoding(leaf.map { $0 + 1 })
