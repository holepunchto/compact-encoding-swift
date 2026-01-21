import Testing

@testable import CompactEncoding

@Test func testUInt8() throws {
  var state = State()

  Primitive.UInt8().preencode(&state, 12)
  state.allocate()

  try Primitive.UInt8().encode(&state, 12)
  #expect(state.buffer[0] == 12)

  state.rewind()

  let value = try Primitive.UInt8().decode(&state)
  #expect(value == 12)
}

@Test func testUInt16() throws {
  var state = State()

  Primitive.UInt16().preencode(&state, 12 | (34 << 8))
  state.allocate()

  try Primitive.UInt16().encode(&state, 12 | (34 << 8))
  #expect(state.buffer[0] == 12)
  #expect(state.buffer[1] == 34)

  state.rewind()

  let value = try Primitive.UInt16().decode(&state)
  #expect(value == 12 | (34 << 8))
}

@Test func testUInt32() throws {
  var state = State()

  Primitive.UInt32().preencode(&state, 12 | (34 << 8) | (56 << 16) | (78 << 24))
  state.allocate()

  try Primitive.UInt32().encode(&state, 12 | (34 << 8) | (56 << 16) | (78 << 24))
  #expect(state.buffer[0] == 12)
  #expect(state.buffer[1] == 34)
  #expect(state.buffer[2] == 56)
  #expect(state.buffer[3] == 78)

  state.rewind()

  let value = try Primitive.UInt32().decode(&state)
  #expect(value == 12 | (34 << 8) | (56 << 16) | (78 << 24))
}
