import Foundation

extension Primitive {
  public struct JSON: Codec {
    // Value is Any because JSON represents a heterogeneous union (object, array, string, number,
    // boolean, null). Callers cast the decoded result to the expected Swift type.
    public typealias Value = Any

    public init() {}

    private let buffer = Primitive.Buffer()

    public func preencode(_ state: inout State, _ value: Value) {
      let data =
        (try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)) ?? Data()
      buffer.preencode(&state, data)
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      let data = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
      try buffer.encode(&state, data)
    }

    public func decode(_ state: inout State) throws -> Value {
      let data = try buffer.decode(&state)
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
  }
}
