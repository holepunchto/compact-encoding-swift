import Foundation

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

public func encode<C: Codec>(_ codec: C, _ value: C.Value) throws -> Data {
  var state = State()

  codec.preencode(&state, value)

  state.allocate()

  try codec.encode(&state, value)

  return state.buffer
}

public func decode<C: Codec>(_ codec: C, _ data: Data) throws -> C.Value {
  var state = State(data)

  return try codec.decode(&state)
}
