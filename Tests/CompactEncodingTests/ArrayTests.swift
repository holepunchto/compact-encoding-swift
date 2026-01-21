import Testing

@testable import CompactEncoding

@Test func testArrayUInt() throws {
  var state = State()

  Primitive.Array(Primitive.UInt()).preencode(&state, [1, 2, 3])
  state.allocate()

  try Primitive.Array(Primitive.UInt()).encode(&state, [1, 2, 3])
  #expect(state.buffer[0] == 3)
  #expect(state.buffer[1] == 1)
  #expect(state.buffer[2] == 2)
  #expect(state.buffer[3] == 3)

  state.rewind()

  let value = try Primitive.Array(Primitive.UInt()).decode(&state)
  #expect(value == [1, 2, 3])
}
