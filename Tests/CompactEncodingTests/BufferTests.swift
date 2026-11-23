import Foundation
import Testing

@testable import CompactEncoding

@Test func testBufferDecodeHugeCountThrows() throws {
  // A 0xff-prefixed varint declares count = UInt.max with no bytes following.
  // Narrowing that to Int traps, so it is rejected before the conversion.
  var state = State(Data([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))

  #expect(throws: DecodingError.outOfBounds) {
    _ = try Primitive.Buffer().decode(&state)
  }
}

@Test func testBuffer() throws {
  var state = State()

  let input = Data([0xde, 0xad, 0xbe, 0xef])

  Primitive.Buffer().preencode(&state, input)
  state.allocate()

  try Primitive.Buffer().encode(&state, input)
  #expect(state.buffer[0] == 4)
  #expect(state.buffer[1] == 0xde)
  #expect(state.buffer[2] == 0xad)
  #expect(state.buffer[3] == 0xbe)
  #expect(state.buffer[4] == 0xef)

  state.rewind()

  let decoded = try Primitive.Buffer().decode(&state)
  #expect(decoded == input)
}

@Test func testEmptyBuffer() throws {
  var state = State()

  let input = Data()

  Primitive.Buffer().preencode(&state, input)
  state.allocate()

  try Primitive.Buffer().encode(&state, input)
  #expect(state.buffer[0] == 0)

  state.rewind()

  let decoded = try Primitive.Buffer().decode(&state)
  #expect(decoded == input)
}
