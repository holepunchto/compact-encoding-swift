public struct UInt8: Codec {
  public typealias Value = Swift.UInt8

  public static func preencode(_ state: inout State, _ value: Value) {
    state.end += 1
  }

  public static func encode(_ state: inout State, _ value: Value) throws {
    guard state.start < state.end else {
      throw EncodingError.outOfBounds
    }

    state.buffer[state.start] = value

    state.start += 1
  }

  public static func decode(_ state: inout State) throws -> Value {
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

  public static func preencode(_ state: inout State, _ value: Value) {
    state.end += 2
  }

  public static func encode(_ state: inout State, _ value: Value) throws {
    guard state.start + 1 < state.end else {
      throw EncodingError.outOfBounds
    }

    state.buffer[state.start] = Swift.UInt8(value & 0xff)
    state.buffer[state.start + 1] = Swift.UInt8((value >> 8) & 0xff)

    state.start += 2
  }

  public static func decode(_ state: inout State) throws -> Value {
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

  public static func preencode(_ state: inout State, _ value: Value) {
    state.end += 4
  }

  public static func encode(_ state: inout State, _ value: Value) throws {
    guard state.start + 3 < state.end else {
      throw EncodingError.outOfBounds
    }

    state.buffer[state.start] = Swift.UInt8(value & 0xff)
    state.buffer[state.start + 1] = Swift.UInt8((value >> 8) & 0xff)
    state.buffer[state.start + 2] = Swift.UInt8((value >> 16) & 0xff)
    state.buffer[state.start + 3] = Swift.UInt8((value >> 24) & 0xff)

    state.start += 4
  }

  public static func decode(_ state: inout State) throws -> Value {
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

  public static func preencode(_ state: inout State, _ value: Value) {
    state.end += 8
  }

  public static func encode(_ state: inout State, _ value: Value) throws {
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

  public static func decode(_ state: inout State) throws -> Value {
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
