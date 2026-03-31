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

@Test func testArrayString() throws {
  var state = State()

  let input: [String] = ["hello", "world"]

  Primitive.Array(Primitive.String()).preencode(&state, input)
  state.allocate()

  try Primitive.Array(Primitive.String()).encode(&state, input)
  // length prefix: 2
  #expect(state.buffer[0] == 2)

  state.rewind()

  let value = try Primitive.Array(Primitive.String()).decode(&state)
  #expect(value == ["hello", "world"])
}

@Test func testArrayBool() throws {
  var state = State()

  let input: [Bool] = [true, false, true]

  Primitive.Array(Primitive.Bool()).preencode(&state, input)
  state.allocate()

  try Primitive.Array(Primitive.Bool()).encode(&state, input)
  #expect(state.buffer[0] == 3)
  #expect(state.buffer[1] == 1)
  #expect(state.buffer[2] == 0)
  #expect(state.buffer[3] == 1)

  state.rewind()

  let value = try Primitive.Array(Primitive.Bool()).decode(&state)
  #expect(value == [true, false, true])
}

@Test func testArrayEmpty() throws {
  var state = State()

  let input: [Swift.UInt] = []

  Primitive.Array(Primitive.UInt()).preencode(&state, input)
  state.allocate()

  try Primitive.Array(Primitive.UInt()).encode(&state, input)
  #expect(state.buffer[0] == 0)

  state.rewind()

  let value = try Primitive.Array(Primitive.UInt()).decode(&state)
  #expect(value == [])
}
