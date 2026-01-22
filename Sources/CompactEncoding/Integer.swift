extension Primitive {
  public struct UInt8: Codec {
    public typealias Value = Swift.UInt8

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 1
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start < state.end else {
        throw EncodingError.outOfBounds
      }

      state.buffer[state.start] = value

      state.start += 1
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start < state.end else {
        throw DecodingError.outOfBounds
      }

      let value = state.buffer[state.start]

      state.start += 1

      return value
    }
  }

  public struct UInt16: Codec {
    public typealias Value = Swift.UInt16

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 2
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start + 1 < state.end else {
        throw EncodingError.outOfBounds
      }

      state.buffer[state.start] = Swift.UInt8(value & 0xff)
      state.buffer[state.start + 1] = Swift.UInt8((value >> 8) & 0xff)

      state.start += 2
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start + 1 < state.end else {
        throw DecodingError.outOfBounds
      }

      let value =
        Swift.UInt16(state.buffer[state.start])
        | (Swift.UInt16(state.buffer[state.start + 1]) << 8)

      state.start += 2

      return value
    }
  }

  public struct UInt32: Codec {
    public typealias Value = Swift.UInt32

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 4
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start + 3 < state.end else {
        throw EncodingError.outOfBounds
      }

      state.buffer[state.start] = Swift.UInt8(value & 0xff)
      state.buffer[state.start + 1] = Swift.UInt8((value >> 8) & 0xff)
      state.buffer[state.start + 2] = Swift.UInt8((value >> 16) & 0xff)
      state.buffer[state.start + 3] = Swift.UInt8((value >> 24) & 0xff)

      state.start += 4
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start + 3 < state.end else {
        throw DecodingError.outOfBounds
      }

      let value =
        Swift.UInt32(state.buffer[state.start])
        | (Swift.UInt32(state.buffer[state.start + 1]) << 8)
        | (Swift.UInt32(state.buffer[state.start + 2]) << 16)
        | (Swift.UInt32(state.buffer[state.start + 3]) << 24)

      state.start += 4

      return value
    }
  }

  public struct UInt64: Codec {
    public typealias Value = Swift.UInt64

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += 8
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.start + 7 < state.end else {
        throw EncodingError.outOfBounds
      }

      state.buffer[state.start] = Swift.UInt8(value & 0xff)
      state.buffer[state.start + 1] = Swift.UInt8((value >> 8) & 0xff)
      state.buffer[state.start + 2] = Swift.UInt8((value >> 16) & 0xff)
      state.buffer[state.start + 3] = Swift.UInt8((value >> 24) & 0xff)
      state.buffer[state.start + 4] = Swift.UInt8((value >> 32) & 0xff)
      state.buffer[state.start + 5] = Swift.UInt8((value >> 40) & 0xff)
      state.buffer[state.start + 6] = Swift.UInt8((value >> 48) & 0xff)
      state.buffer[state.start + 7] = Swift.UInt8((value >> 56) & 0xff)

      state.start += 8
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start + 7 < state.end else {
        throw DecodingError.outOfBounds
      }

      let value =
        Swift.UInt64(state.buffer[state.start])
        | (Swift.UInt64(state.buffer[state.start + 1]) << 8)
        | (Swift.UInt64(state.buffer[state.start + 2]) << 16)
        | (Swift.UInt64(state.buffer[state.start + 3]) << 24)
        | (Swift.UInt64(state.buffer[state.start + 4]) << 32)
        | (Swift.UInt64(state.buffer[state.start + 5]) << 40)
        | (Swift.UInt64(state.buffer[state.start + 6]) << 48)
        | (Swift.UInt64(state.buffer[state.start + 7]) << 56)

      state.start += 8

      return value
    }
  }

  public struct UInt: Codec {
    public typealias Value = Swift.UInt

    public func preencode(_ state: inout State, _ value: Value) {
      state.end +=
        value <= 0xfc
        ? 1
        : value <= 0xffff
          ? 3
          : value <= 0xffff_ffff
            ? 5
            : 9
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      if value <= 0xfc {
        return try UInt8().encode(&state, Swift.UInt8(value))
      }

      guard state.start < state.end else {
        throw EncodingError.outOfBounds
      }

      if value <= 0xffff {
        state.buffer[state.start] = 0xfd

        state.start += 1

        return try UInt16().encode(&state, Swift.UInt16(value))
      }

      if value <= 0xffff_ffff {
        state.buffer[state.start] = 0xfe

        state.start += 1

        return try UInt32().encode(&state, Swift.UInt32(value))
      }

      state.buffer[state.start] = 0xff

      state.start += 1

      return try UInt64().encode(&state, Swift.UInt64(value))
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.start < state.end else {
        throw DecodingError.outOfBounds
      }

      let value = try UInt8().decode(&state)

      if value <= 0xfc {
        return Swift.UInt(value)
      }

      if value == 0xfd {
        return Swift.UInt(try UInt16().decode(&state))
      }

      if value == 0xfe {
        return Swift.UInt(try UInt32().decode(&state))
      }

      return Swift.UInt(try UInt64().decode(&state))
    }
  }

  public struct Int8: Codec {
    public typealias Value = Swift.Int8

    public func preencode(_ state: inout State, _ value: Value) {
      UInt8().preencode(&state, zigZagEncode(value))
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try UInt8().encode(&state, zigZagEncode(value))
    }

    public func decode(_ state: inout State) throws -> Value {
      return zigZagDecode(try UInt8().decode(&state))
    }
  }

  public struct Int16: Codec {
    public typealias Value = Swift.Int16

    public func preencode(_ state: inout State, _ value: Value) {
      UInt16().preencode(&state, zigZagEncode(value))
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try UInt16().encode(&state, zigZagEncode(value))
    }

    public func decode(_ state: inout State) throws -> Value {
      return zigZagDecode(try UInt16().decode(&state))
    }
  }

  public struct Int32: Codec {
    public typealias Value = Swift.Int32

    public func preencode(_ state: inout State, _ value: Value) {
      UInt32().preencode(&state, zigZagEncode(value))
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try UInt32().encode(&state, zigZagEncode(value))
    }

    public func decode(_ state: inout State) throws -> Value {
      return zigZagDecode(try UInt32().decode(&state))
    }
  }

  public struct Int64: Codec {
    public typealias Value = Swift.Int64

    public func preencode(_ state: inout State, _ value: Value) {
      UInt64().preencode(&state, zigZagEncode(value))
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try UInt64().encode(&state, zigZagEncode(value))
    }

    public func decode(_ state: inout State) throws -> Value {
      return zigZagDecode(try UInt64().decode(&state))
    }
  }

  public struct Int: Codec {
    public typealias Value = Swift.Int

    public func preencode(_ state: inout State, _ value: Value) {
      UInt().preencode(&state, zigZagEncode(value))
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try UInt().encode(&state, zigZagEncode(value))
    }

    public func decode(_ state: inout State) throws -> Value {
      return zigZagDecode(try UInt().decode(&state))
    }
  }
}
