import Foundation
import Testing

@testable import CompactEncoding

@Test func testBoolTrue() throws {
  var state = State()

  Primitive.Bool().preencode(&state, true)
  #expect(state.end == 1)
  state.allocate()

  try Primitive.Bool().encode(&state, true)
  #expect(state.buffer[0] == 1)

  state.rewind()

  let value = try Primitive.Bool().decode(&state)
  #expect(value == true)
}

@Test func testBoolFalse() throws {
  var state = State()

  Primitive.Bool().preencode(&state, false)
  #expect(state.end == 1)
  state.allocate()

  try Primitive.Bool().encode(&state, false)
  #expect(state.buffer[0] == 0)

  state.rewind()

  let value = try Primitive.Bool().decode(&state)
  #expect(value == false)
}

@Test func testBoolMultiple() throws {
  var state = State()

  Primitive.Bool().preencode(&state, true)
  Primitive.Bool().preencode(&state, false)
  Primitive.Bool().preencode(&state, true)
  #expect(state.end == 3)

  state.allocate()

  try Primitive.Bool().encode(&state, true)
  try Primitive.Bool().encode(&state, false)
  try Primitive.Bool().encode(&state, true)
  #expect(state.buffer == Data([1, 0, 1]))

  state.rewind()

  #expect(try Primitive.Bool().decode(&state) == true)
  #expect(try Primitive.Bool().decode(&state) == false)
  #expect(try Primitive.Bool().decode(&state) == true)
  #expect(state.start == state.end)
}

@Test func testBoolDecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Bool().decode(&state)
  }
}

@Test func testBoolEncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Bool().encode(&state, true)
  }
}
