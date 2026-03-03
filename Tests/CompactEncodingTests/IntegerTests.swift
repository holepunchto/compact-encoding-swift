import Foundation
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

@Test func testUInt() throws {
  var state = State()

  Primitive.UInt().preencode(&state, 42)
  #expect(state.start == 0)
  #expect(state.end == 1)
  Primitive.UInt().preencode(&state, 4200)
  #expect(state.start == 0)
  #expect(state.end == 4)
  Primitive.UInt().preencode(&state, Swift.UInt.max)
  #expect(state.start == 0)
  #expect(state.end == 13)

  state.allocate()

  try Primitive.UInt().encode(&state, 42)
  #expect(
    state.buffer == Data([42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
  try Primitive.UInt().encode(&state, 4200)
  #expect(
    state.buffer == Data([42, 0xfd, 104, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
  try Primitive.UInt().encode(&state, Swift.UInt.max)
  #expect(
    state.buffer == Data([42, 0xfd, 104, 16, 0xff, 255, 255, 255, 255, 255, 255, 255, 255]))

  state.rewind()

  var value = try Primitive.UInt().decode(&state)
  #expect(value == 42)
  value = try Primitive.UInt().decode(&state)
  #expect(value == 4200)
  value = try Primitive.UInt().decode(&state)
  #expect(value == Swift.UInt.max)
  #expect(state.start == state.end)
  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.UInt().decode(&state)
  }
}
