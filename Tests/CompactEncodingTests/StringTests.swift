import Foundation
import Testing

@testable import CompactEncoding

@Test func testString() throws {
  var state = State()

  let input = "hello"

  Primitive.String().preencode(&state, input)
  #expect(state.end == 6)
  state.allocate()

  try Primitive.String().encode(&state, input)
  #expect(state.buffer[0] == 5)
  #expect(state.buffer[1] == 0x68)  // h
  #expect(state.buffer[2] == 0x65)  // e
  #expect(state.buffer[3] == 0x6c)  // l
  #expect(state.buffer[4] == 0x6c)  // l
  #expect(state.buffer[5] == 0x6f)  // o

  state.rewind()

  let decoded = try Primitive.String().decode(&state)
  #expect(decoded == input)
  #expect(state.start == state.end)
}

@Test func testEmptyString() throws {
  var state = State()

  let input = ""

  Primitive.String().preencode(&state, input)
  #expect(state.end == 1)
  state.allocate()

  try Primitive.String().encode(&state, input)
  #expect(state.buffer[0] == 0)

  state.rewind()

  let decoded = try Primitive.String().decode(&state)
  #expect(decoded == input)
  #expect(state.start == state.end)
}

@Test func testUTF8Multibyte() throws {
  var state = State()

  let input = "héllo"

  Primitive.UTF8().preencode(&state, input)
  #expect(state.end == 7)
  state.allocate()

  try Primitive.UTF8().encode(&state, input)
  // "héllo" is 6 bytes in UTF-8 (é is 2 bytes)
  #expect(state.buffer[0] == 6)
  #expect(state.buffer[1] == 0x68)  // h
  #expect(state.buffer[2] == 0xc3)  // é (first byte)
  #expect(state.buffer[3] == 0xa9)  // é (second byte)
  #expect(state.buffer[4] == 0x6c)  // l
  #expect(state.buffer[5] == 0x6c)  // l
  #expect(state.buffer[6] == 0x6f)  // o

  state.rewind()

  let decoded = try Primitive.UTF8().decode(&state)
  #expect(decoded == input)
  #expect(state.start == state.end)
}

@Test func testUTF8Emoji() throws {
  var state = State()

  let input = "hi 👋"

  Primitive.UTF8().preencode(&state, input)
  #expect(state.end == 8)
  state.allocate()

  try Primitive.UTF8().encode(&state, input)
  // "hi " is 3 bytes, 👋 is 4 bytes = 7 bytes total
  #expect(state.buffer[0] == 7)
  #expect(state.buffer[1] == 0x68)  // h
  #expect(state.buffer[2] == 0x69)  // i
  #expect(state.buffer[3] == 0x20)  // space
  #expect(state.buffer[4] == 0xf0)  // 👋 (first byte)
  #expect(state.buffer[5] == 0x9f)  // 👋 (second byte)
  #expect(state.buffer[6] == 0x91)  // 👋 (third byte)
  #expect(state.buffer[7] == 0x8b)  // 👋 (fourth byte)

  state.rewind()

  let decoded = try Primitive.UTF8().decode(&state)
  #expect(decoded == input)
  #expect(state.start == state.end)
}

@Test func testStringMultiple() throws {
  var state = State()

  let a = "hello"
  let b = "world"

  Primitive.String().preencode(&state, a)
  Primitive.String().preencode(&state, b)
  #expect(state.end == 12)
  state.allocate()

  try Primitive.String().encode(&state, a)
  try Primitive.String().encode(&state, b)

  state.rewind()

  #expect(try Primitive.String().decode(&state) == "hello")
  #expect(try Primitive.String().decode(&state) == "world")
  #expect(state.start == state.end)
}

@Test func testStringLongMultibyteLengthPrefix() throws {
  var state = State()

  // 253 bytes triggers the 0xfd multi-byte length prefix
  let input = Swift.String(repeating: "a", count: 253)

  Primitive.String().preencode(&state, input)
  // 3 bytes for length prefix (0xfd + 2-byte LE) + 253 bytes = 256
  #expect(state.end == 256)
  state.allocate()

  try Primitive.String().encode(&state, input)
  #expect(state.buffer[0] == 0xfd)
  #expect(state.buffer[1] == 253)
  #expect(state.buffer[2] == 0)

  state.rewind()

  let decoded = try Primitive.String().decode(&state)
  #expect(decoded == input)
  #expect(state.start == state.end)
}

@Test func testStringDecodeOutOfBounds() throws {
  // Length prefix says 5 bytes but only 3 bytes follow
  var state = State(Data([5, 0x68, 0x65, 0x6c]))

  #expect(throws: DecodingError.outOfBounds) {
    _ = try Primitive.String().decode(&state)
  }
}

@Test func testStringEncodeOutOfBounds() throws {
  var state = State()

  // Preencode but don't allocate — buffer is empty
  Primitive.String().preencode(&state, "hello")

  state.start = 0
  state.end = 0

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.String().encode(&state, "hello")
  }
}
