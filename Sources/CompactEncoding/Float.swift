extension Primitive {
  public struct Float32: Codec {
    public typealias Value = Swift.Float

    public init() {}

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

      var bits: Swift.UInt32 = 0
      for i in 0..<4 {
        bits |= Swift.UInt32(state.buffer[state.start + i]) << (8 * i)
      }

      state.start += 4

      return Swift.Float(bitPattern: bits)
    }
  }

  public typealias Float = Float32

  public struct Float64: Codec {
    public typealias Value = Swift.Double

    public init() {}

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

      var bits: Swift.UInt64 = 0
      for i in 0..<8 {
        bits |= Swift.UInt64(state.buffer[state.start + i]) << (8 * i)
      }

      state.start += 8

      return Swift.Double(bitPattern: bits)
    }
  }

  public typealias Double = Float64
}
