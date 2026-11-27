import Foundation

extension Primitive {
  // An absent value and an empty buffer both write a count of zero, and a count
  // of zero reads back as absent: the two are told apart by which codec the
  // caller picked, not by the bytes.
  public struct OptionalBuffer: Codec {
    public typealias Value = Data?

    public init() {}

    private let buffer = Primitive.Buffer()

    public func preencode(_ state: inout State, _ value: Value) {
      buffer.preencode(&state, value ?? Data())
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      try buffer.encode(&state, value ?? Data())
    }

    public func decode(_ state: inout State) throws -> Value {
      let data = try buffer.decode(&state)

      return data.isEmpty ? nil : data
    }
  }
}
