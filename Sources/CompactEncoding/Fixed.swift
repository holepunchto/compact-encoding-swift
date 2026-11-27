import Foundation

extension Primitive {
  public struct Fixed: Codec {
    public typealias Value = Data

    private let size: Swift.Int

    public init(_ size: Swift.Int) {
      self.size = size
    }

    public func preencode(_ state: inout State, _ value: Value) {
      state.end += size
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      guard value.count == size else {
        throw EncodingError.invalidSize
      }

      guard state.remaining >= size else {
        throw EncodingError.outOfBounds
      }

      state.buffer.replaceSubrange(state.start..<state.start + size, with: value)

      state.start += size
    }

    public func decode(_ state: inout State) throws -> Value {
      guard state.remaining >= size else {
        throw DecodingError.outOfBounds
      }

      let data = state.buffer.subdata(in: state.start..<state.start + size)

      state.start += size

      return data
    }
  }
}
