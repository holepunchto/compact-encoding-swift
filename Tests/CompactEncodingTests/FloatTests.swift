import Foundation
import Testing

@testable import CompactEncoding

@Test func testFloat32() throws {
  var state = State()

  let value: Float = 3.14

  Primitive.Float32().preencode(&state, value)
  #expect(state.end == 4)

  state.allocate()

  try Primitive.Float32().encode(&state, value)

  let bits = value.bitPattern
  #expect(state.buffer[0] == UInt8(bits & 0xff))
  #expect(state.buffer[1] == UInt8((bits >> 8) & 0xff))
  #expect(state.buffer[2] == UInt8((bits >> 16) & 0xff))
  #expect(state.buffer[3] == UInt8((bits >> 24) & 0xff))

  state.rewind()

  let decoded = try Primitive.Float32().decode(&state)
  #expect(decoded == value)
}

@Test func testFloat32Zero() throws {
  var state = State()

  Primitive.Float32().preencode(&state, 0.0)
  state.allocate()

  try Primitive.Float32().encode(&state, 0.0)
  #expect(state.buffer == Data([0, 0, 0, 0]))

  state.rewind()

  let decoded = try Primitive.Float32().decode(&state)
  #expect(decoded == 0.0)
}

@Test func testFloat32Negative() throws {
  var state = State()

  let value: Float = -1.5

  Primitive.Float32().preencode(&state, value)
  state.allocate()

  try Primitive.Float32().encode(&state, value)

  state.rewind()

  let decoded = try Primitive.Float32().decode(&state)
  #expect(decoded == value)
}

@Test func testFloat32OutOfBounds() throws {
  var state = State()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Float32().decode(&state)
  }
}

@Test func testFloat64() throws {
  var state = State()

  let value: Double = 3.141592653589793

  Primitive.Float64().preencode(&state, value)
  #expect(state.end == 8)

  state.allocate()

  try Primitive.Float64().encode(&state, value)

  let bits = value.bitPattern
  #expect(state.buffer[0] == UInt8(bits & 0xff))
  #expect(state.buffer[1] == UInt8((bits >> 8) & 0xff))
  #expect(state.buffer[2] == UInt8((bits >> 16) & 0xff))
  #expect(state.buffer[3] == UInt8((bits >> 24) & 0xff))
  #expect(state.buffer[4] == UInt8((bits >> 32) & 0xff))
  #expect(state.buffer[5] == UInt8((bits >> 40) & 0xff))
  #expect(state.buffer[6] == UInt8((bits >> 48) & 0xff))
  #expect(state.buffer[7] == UInt8((bits >> 56) & 0xff))

  state.rewind()

  let decoded = try Primitive.Float64().decode(&state)
  #expect(decoded == value)
}

@Test func testFloat64Zero() throws {
  var state = State()

  Primitive.Float64().preencode(&state, 0.0)
  state.allocate()

  try Primitive.Float64().encode(&state, 0.0)
  #expect(state.buffer == Data([0, 0, 0, 0, 0, 0, 0, 0]))

  state.rewind()

  let decoded = try Primitive.Float64().decode(&state)
  #expect(decoded == 0.0)
}

@Test func testFloat64Negative() throws {
  var state = State()

  let value: Double = -1.5

  Primitive.Float64().preencode(&state, value)
  state.allocate()

  try Primitive.Float64().encode(&state, value)

  state.rewind()

  let decoded = try Primitive.Float64().decode(&state)
  #expect(decoded == value)
}

@Test func testFloat64OutOfBounds() throws {
  var state = State()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Float64().decode(&state)
  }
}

@Test func testFloatAlias() throws {
  var state = State()

  let value: Float = 2.5

  Primitive.Float().preencode(&state, value)
  state.allocate()

  try Primitive.Float().encode(&state, value)

  state.rewind()

  let decoded = try Primitive.Float().decode(&state)
  #expect(decoded == value)
}

@Test func testDoubleAlias() throws {
  var state = State()

  let value: Double = 2.5

  Primitive.Double().preencode(&state, value)
  state.allocate()

  try Primitive.Double().encode(&state, value)

  state.rewind()

  let decoded = try Primitive.Double().decode(&state)
  #expect(decoded == value)
}
