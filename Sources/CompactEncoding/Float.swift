extension Primitive {
  public struct Float32: Codec {
    public typealias Value = Swift.Float

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 4
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start + 3 < state.end else {
        throw EncodingError.outOfBounds
      }

      let bits = value.bitPattern

      state.buffer[state.start] = Swift.UInt8(bits & 0xff)
      state.buffer[state.start + 1] = Swift.UInt8((bits >> 8) & 0xff)
      state.buffer[state.start + 2] = Swift.UInt8((bits >> 16) & 0xff)
      state.buffer[state.start + 3] = Swift.UInt8((bits >> 24) & 0xff)

      state.start += 4
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start + 3 < state.end else {
        throw DecodingError.outOfBounds
      }

      let bits =
        Swift.UInt32(state.buffer[state.start])
        | (Swift.UInt32(state.buffer[state.start + 1]) << 8)
        | (Swift.UInt32(state.buffer[state.start + 2]) << 16)
        | (Swift.UInt32(state.buffer[state.start + 3]) << 24)

      state.start += 4

      return Float(bitPattern: bits)
    }
  }

  public typealias Float = Float32

  public struct Float64: Codec {
    public typealias Value = Swift.Double

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 8
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start + 7 < state.end else {
        throw EncodingError.outOfBounds
      }

      let bits = value.bitPattern

      state.buffer[state.start] = Swift.UInt8(bits & 0xff)
      state.buffer[state.start + 1] = Swift.UInt8((bits >> 8) & 0xff)
      state.buffer[state.start + 2] = Swift.UInt8((bits >> 16) & 0xff)
      state.buffer[state.start + 3] = Swift.UInt8((bits >> 24) & 0xff)
      state.buffer[state.start + 4] = Swift.UInt8((bits >> 32) & 0xff)
      state.buffer[state.start + 5] = Swift.UInt8((bits >> 40) & 0xff)
      state.buffer[state.start + 6] = Swift.UInt8((bits >> 48) & 0xff)
      state.buffer[state.start + 7] = Swift.UInt8((bits >> 56) & 0xff)

      state.start += 8
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start + 7 < state.end else {
        throw DecodingError.outOfBounds
      }

      let bits =
        Swift.UInt64(state.buffer[state.start])
        | (Swift.UInt64(state.buffer[state.start + 1]) << 8)
        | (Swift.UInt64(state.buffer[state.start + 2]) << 16)
        | (Swift.UInt64(state.buffer[state.start + 3]) << 24)
        | (Swift.UInt64(state.buffer[state.start + 4]) << 32)
        | (Swift.UInt64(state.buffer[state.start + 5]) << 40)
        | (Swift.UInt64(state.buffer[state.start + 6]) << 48)
        | (Swift.UInt64(state.buffer[state.start + 7]) << 56)

      state.start += 8

      return Double(bitPattern: bits)
    }
  }

  public typealias Double = Float64
}
