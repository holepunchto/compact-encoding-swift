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

  // UTF8 encodes "hello" as [0x05, h,e,l,l,o] = 6 bytes. Frame prefix = varint(6) = 0x06.
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

  // empty buffer encodes as 1 byte (length varint 0x00).
  // Frame: length prefix 0x01, then that 1 byte → [0x01, 0x00]
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

@Test func testFrameEncodeOutOfBounds() throws {
  // Zero-size buffer — encode without preencode/allocate
  var state = State()
  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Frame(Primitive.UInt()).encode(&state, 42)
  }
}

@Test func testFrameDecodeOutOfBounds() throws {
  // Truncated buffer: declares a 10-byte frame but only 3 bytes follow
  let raw = Data([0x0a, 0x01, 0x02, 0x03])
  var state = State(raw)
  #expect(throws: DecodingError.outOfBounds) {
    _ = try Primitive.Frame(Primitive.UInt()).decode(&state)
  }
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
