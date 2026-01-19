public protocol Codec {
  associatedtype Value

  static func preencode(_ state: inout State, _ value: Value)

  static func encode(_ state: inout State, _ value: Value) throws

  static func decode(_ state: inout State) throws -> Value
}

public enum EncodingError: Error {
  case outOfBounds
}

public enum DecodingError: Error {
  case outOfBounds
}
