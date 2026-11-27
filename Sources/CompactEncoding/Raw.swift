import Foundation

extension Primitive {
  public struct Raw: Codec {
    public typealias Value = Data

    public init() {}

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += value.count
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard state.remaining >= value.count else {
        throw EncodingError.outOfBounds
      }

      state.buffer.replaceSubrange(state.start..<state.start + value.count, with: value)

      state.start += value.count
    }

    // Raw has no form of its own, so it takes everything left rather than
    // stopping at a length it wrote.
    public func decode(_ state: inout State) throws -> Value {
      let data = state.buffer.subdata(in: state.start..<state.end)

      state.start = state.end

      return data
    }
  }
}
