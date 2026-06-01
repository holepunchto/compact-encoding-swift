import Foundation

extension Primitive {
  public struct JSON: Codec {
    // Value is Any because JSON represents a heterogeneous union (object, array, string, number,
    // boolean, null). Callers cast the decoded result to the expected Swift type.
    public typealias Value = Any

    public init() {}

    private let buffer = Primitive.Buffer()

    // .sortedKeys makes object output deterministic: Swift's Dictionary is
    // unordered and JSONSerialization is otherwise free to emit keys in any
    // order, so without this the same value can encode to different bytes from
    // run to run — breaking anything that hashes or compares the encoding.
    private static let options: JSONSerialization.WritingOptions = [.fragmentsAllowed, .sortedKeys]

    public func preencode(_ state: inout State, _ value: Value) {
      // preencode can't throw; if serialization fails here it fails again in
      // encode, which does throw, so the error still surfaces there.
      let data =
        (try? JSONSerialization.data(withJSONObject: value, options: Self.options)) ?? Data()
      buffer.preencode(&state, data)
    }

    public func encode(_ state: inout State, _ value: Value) throws {
      let data = try JSONSerialization.data(withJSONObject: value, options: Self.options)
      try buffer.encode(&state, data)
    }

    public func decode(_ state: inout State) throws -> Value {
      let data = try buffer.decode(&state)
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
  }
}
