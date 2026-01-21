extension Primitive {
  public struct Array<C: Codec>: Codec {
    public typealias Value = Swift.Array<C.Value>

    private let codec: C

    public init(_ codec: C) {
      self.codec = codec
    }

    public func preencode(_ state: inout State, _ value: Value) {
      Primitive.UInt().preencode(&state, Swift.UInt(value.count))

      for element in value {
        codec.preencode(&state, element)
      }
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try Primitive.UInt().encode(&state, Swift.UInt(value.count))

      for element in value {
        try codec.encode(&state, element)
      }
    }

    public func decode(_ state: inout State) throws -> Value {
      let count = try Primitive.UInt().decode(&state)

      var result = Value()

      result.reserveCapacity(Int(count))

      for _ in 0..<count {
        result.append(try codec.decode(&state))
      }

      return result
    }
  }
}
