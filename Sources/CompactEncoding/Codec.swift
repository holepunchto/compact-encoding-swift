public protocol Codec {
  associatedtype Value

  func preencode(_ state: inout State, _ value: Value)

  func encode(_ state: inout State, _ value: Value) throws

  func decode(_ state: inout State) throws -> Value
}

public enum EncodingError: Error {
  case outOfBounds
}

public enum DecodingError: Error {
  case outOfBounds
}
