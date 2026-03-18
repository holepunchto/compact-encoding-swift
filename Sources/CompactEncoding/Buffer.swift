import Foundation

extension Primitive {
  public struct Buffer: Codec {
    public typealias Value = Data

    public init() {}

    public func preencode(_ state: inout State, _ value: Value) {
      let count = value.count

      Primitive.UInt().preencode(&state, Swift.UInt(count))

      state.end += count
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      let count = value.count

      try Primitive.UInt().encode(&state, Swift.UInt(count))

      guard state.remaining >= count else {
        throw EncodingError.outOfBounds
      }

      state.buffer.replaceSubrange(state.start..<state.start + count, with: value)

      state.start += count
    }

    public func decode(_ state: inout State) throws -> Value {
      let count = Swift.Int(try Primitive.UInt().decode(&state))

      guard state.remaining >= count else {
        throw DecodingError.outOfBounds
      }

      let data = state.buffer.subdata(in: state.start..<state.start + count)

      state.start += count

      return data
    }
  }
}
