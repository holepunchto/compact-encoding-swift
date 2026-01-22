extension Primitive {
  public struct Bool: Codec {
    public typealias Value = Swift.Bool

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 1
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start < state.end else {
        throw EncodingError.outOfBounds
      }

      state.buffer[state.start] = value ? 1 : 0

      state.start += 1
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start < state.end else {
        throw DecodingError.outOfBounds
      }

      let value = state.buffer[state.start] == 1

      state.start += 1

      return value
    }
  }
}
