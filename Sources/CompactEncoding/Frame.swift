import Foundation

extension Primitive {
  public struct Frame<C: Codec>: Codec {
    public typealias Value = C.Value

    private let codec: C

    public init(_ codec: C) {
      self.codec = codec
    }

    public func preencode(_ state: inout State, _ value: C.Value) {
      var inner = State()
      codec.preencode(&inner, value)
      let byteCount = inner.end
      Primitive.UInt().preencode(&state, Swift.UInt(byteCount))
      state.end += byteCount
    }

    public func encode(_ state: inout State, _ value: C.Value) throws {
      var inner = State()
      codec.preencode(&inner, value)
      let byteCount = inner.end
      inner.allocate()
      try codec.encode(&inner, value)
      try Primitive.UInt().encode(&state, Swift.UInt(byteCount))
      guard state.remaining >= byteCount else { throw EncodingError.outOfBounds }
      state.buffer.replaceSubrange(state.start..<(state.start + byteCount), with: inner.buffer)
      state.start += byteCount
    }

    public func decode(_ state: inout State) throws -> C.Value {
      let length = Swift.Int(try Primitive.UInt().decode(&state))
      guard state.remaining >= length else { throw DecodingError.outOfBounds }
      let subData = Data(state.buffer[state.start..<(state.start + length)])
      state.start += length
      var inner = State(subData)
      return try codec.decode(&inner)
    }
  }
}
