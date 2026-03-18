import Foundation

extension Primitive {
  public struct UTF8: Codec {
    public typealias Value = Swift.String

    public init() {}

    private let buffer = Primitive.Buffer()

    public func preencode(_ state: inout State, _ value: Value) {
      buffer.preencode(&state, Data(value.utf8))
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try buffer.encode(&state, Data(value.utf8))
    }

    public func decode(_ state: inout State) throws -> Value {
      let data = try buffer.decode(&state)
      return Swift.String(decoding: data, as: Swift.UTF8.self)
    }
  }

  public typealias String = UTF8
}
