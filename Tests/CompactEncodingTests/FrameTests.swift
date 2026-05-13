import Foundation
import Testing

@testable import CompactEncoding

@Test func testFrameUInt() throws {
  var state = State()
  Primitive.Frame(Primitive.UInt()).preencode(&state, 42)
  state.allocate()
  try Primitive.Frame(Primitive.UInt()).encode(&state, 42)

  // 42 encodes as 1 byte (0x2a), frame length = 1
  let expected: [UInt8] = [0x01, 0x2a]
  #expect(Swift.Array(state.buffer) == expected)

  state.rewind()
  let decoded = try Primitive.Frame(Primitive.UInt()).decode(&state)
  #expect(decoded == 42)
}

@Test func testFrameString() throws {
  var state = State()
  Primitive.Frame(Primitive.UTF8()).preencode(&state, "hello")
  state.allocate()
  try Primitive.Frame(Primitive.UTF8()).encode(&state, "hello")

  // "hello" = 5 bytes, prefixed by length 5, frame length = 6 (1 for length varint + 5 chars)
  let expected: [UInt8] = [0x06, 0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f]
  #expect(Swift.Array(state.buffer) == expected)

  state.rewind()
  let decoded = try Primitive.Frame(Primitive.UTF8()).decode(&state)
  #expect(decoded == "hello")
}

@Test func testFrameEmptyBuffer() throws {
  var state = State()
  Primitive.Frame(Primitive.Buffer()).preencode(&state, Data())
  state.allocate()
  try Primitive.Frame(Primitive.Buffer()).encode(&state, Data())

  // empty buffer = 1 byte (length 0), frame length = 1
  let expected: [UInt8] = [0x01, 0x00]
  #expect(Swift.Array(state.buffer) == expected)

  state.rewind()
  let decoded = try Primitive.Frame(Primitive.Buffer()).decode(&state)
  #expect(decoded == Data())
}

@Test func testFrameNestedWithArray() throws {
  var state = State()
  let codec = Primitive.Frame(Primitive.Array(Primitive.UInt()))
  let input: [UInt] = [1, 2, 3]

  codec.preencode(&state, input)
  state.allocate()
  try codec.encode(&state, input)

  state.rewind()
  let decoded = try codec.decode(&state)
  #expect(decoded == [1, 2, 3])
}

@Test func testFrameDecodeIsolation() throws {
  // Verify that frame decode reads exactly the frame bytes and leaves the rest
  var state = State()
  let frameCodec = Primitive.Frame(Primitive.UInt())
  let uintCodec = Primitive.UInt()

  frameCodec.preencode(&state, 99)
  uintCodec.preencode(&state, 7)
  state.allocate()
  try frameCodec.encode(&state, 99)
  try uintCodec.encode(&state, 7)

  state.rewind()
  let first = try frameCodec.decode(&state)
  let second = try uintCodec.decode(&state)
  #expect(first == 99)
  #expect(second == 7)
}
