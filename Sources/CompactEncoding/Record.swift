extension Primitive {
  public struct Record<C: Codec>: Codec {
    public typealias Value = [Swift.String: C.Value]

    private let codec: C

    public init(_ codec: C) {
      self.codec = codec
    }

    // The key order is the UTF-8 bytes of the keys compared byte by byte, not
    // the comparison Swift gives its strings: the two part company once
    // normalisation differs.
    private func sorted(_ value: Value) -> [(key: Swift.String, value: C.Value)] {
      value.sorted { $0.key.utf8.lexicographicallyPrecedes($1.key.utf8) }
    }

    public func preencode(_ state: inout State, _ value: [Swift.String: C.Value]) {
      Primitive.UInt().preencode(&state, Swift.UInt(value.count))
      for (k, v) in sorted(value) {
        Primitive.UTF8().preencode(&state, k)
        codec.preencode(&state, v)
      }
    }

    public func encode(_ state: inout State, _ value: [Swift.String: C.Value]) throws {
      try Primitive.UInt().encode(&state, Swift.UInt(value.count))
      for (k, v) in sorted(value) {
        try Primitive.UTF8().encode(&state, k)
        try codec.encode(&state, v)
      }
    }

    public func decode(_ state: inout State) throws -> [Swift.String: C.Value] {
      let count = try Primitive.UInt().decode(&state)
      // Each entry is at least one byte (its key length prefix), so a count
      // larger than the bytes left is malformed — reject before looping.
      guard count <= Swift.UInt(state.remaining) else {
        throw DecodingError.outOfBounds
      }
      var result: [Swift.String: C.Value] = [:]
      for _ in 0..<count {
        let k = try Primitive.UTF8().decode(&state)
        let v = try codec.decode(&state)
        result[k] = v
      }
      return result
    }
  }
}
