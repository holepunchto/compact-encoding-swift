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

@Test func testUInt64() throws {
  var state = State()

  Primitive.UInt64().preencode(&state, 0)
  Primitive.UInt64().preencode(&state, Swift.UInt64.max)
  Primitive.UInt64().preencode(&state, 0x0102_0304_0506_0708)
  state.allocate()

  try Primitive.UInt64().encode(&state, 0)
  for i in 0..<8 {
    #expect(state.buffer[i] == 0x00)
  }

  try Primitive.UInt64().encode(&state, Swift.UInt64.max)
  for i in 8..<16 {
    #expect(state.buffer[i] == 0xFF)
  }

  // little-endian byte order
  try Primitive.UInt64().encode(&state, 0x0102_0304_0506_0708)
  #expect(state.buffer[16] == 0x08)
  #expect(state.buffer[17] == 0x07)
  #expect(state.buffer[18] == 0x06)
  #expect(state.buffer[19] == 0x05)
  #expect(state.buffer[20] == 0x04)
  #expect(state.buffer[21] == 0x03)
  #expect(state.buffer[22] == 0x02)
  #expect(state.buffer[23] == 0x01)

  state.rewind()

  #expect(try Primitive.UInt64().decode(&state) == 0)
  #expect(try Primitive.UInt64().decode(&state) == Swift.UInt64.max)
  #expect(try Primitive.UInt64().decode(&state) == 0x0102_0304_0506_0708)
}

@Test func testInt8() throws {
  var state = State()

  // zigzag: 0 → 0, -1 → 1, 1 → 2, -2 → 3
  Primitive.Int8().preencode(&state, 0)
  Primitive.Int8().preencode(&state, -1)
  Primitive.Int8().preencode(&state, 1)
  Primitive.Int8().preencode(&state, -2)
  Primitive.Int8().preencode(&state, Swift.Int8.min)
  Primitive.Int8().preencode(&state, Swift.Int8.max)
  state.allocate()

  try Primitive.Int8().encode(&state, 0)
  #expect(state.buffer[0] == 0)
  try Primitive.Int8().encode(&state, -1)
  #expect(state.buffer[1] == 1)
  try Primitive.Int8().encode(&state, 1)
  #expect(state.buffer[2] == 2)
  try Primitive.Int8().encode(&state, -2)
  #expect(state.buffer[3] == 3)
  try Primitive.Int8().encode(&state, Swift.Int8.min)
  // zigzag(Int8.min) = UInt8.max = 0xFF
  #expect(state.buffer[4] == 0xFF)
  try Primitive.Int8().encode(&state, Swift.Int8.max)
  // zigzag(Int8.max) = UInt8.max - 1 = 0xFE
  #expect(state.buffer[5] == 0xFE)

  state.rewind()

  #expect(try Primitive.Int8().decode(&state) == 0)
  #expect(try Primitive.Int8().decode(&state) == -1)
  #expect(try Primitive.Int8().decode(&state) == 1)
  #expect(try Primitive.Int8().decode(&state) == -2)
  #expect(try Primitive.Int8().decode(&state) == Swift.Int8.min)
  #expect(try Primitive.Int8().decode(&state) == Swift.Int8.max)
}

@Test func testInt16() throws {
  var state = State()

  Primitive.Int16().preencode(&state, 0)
  Primitive.Int16().preencode(&state, -1)
  Primitive.Int16().preencode(&state, 1)
  Primitive.Int16().preencode(&state, -300)
  Primitive.Int16().preencode(&state, Swift.Int16.min)
  Primitive.Int16().preencode(&state, Swift.Int16.max)
  state.allocate()

  try Primitive.Int16().encode(&state, 0)
  // zigzag(0) = 0 → bytes: 0x00 0x00
  #expect(state.buffer[0] == 0x00)
  #expect(state.buffer[1] == 0x00)

  try Primitive.Int16().encode(&state, -1)
  // zigzag(-1) = 1 → bytes: 0x01 0x00
  #expect(state.buffer[2] == 0x01)
  #expect(state.buffer[3] == 0x00)

  try Primitive.Int16().encode(&state, 1)
  // zigzag(1) = 2 → bytes: 0x02 0x00
  #expect(state.buffer[4] == 0x02)
  #expect(state.buffer[5] == 0x00)

  try Primitive.Int16().encode(&state, -300)
  // zigzag(-300) = 599 → bytes: 0x57 0x02
  #expect(state.buffer[6] == 0x57)
  #expect(state.buffer[7] == 0x02)

  try Primitive.Int16().encode(&state, Swift.Int16.min)
  // zigzag(Int16.min) = UInt16.max = 0xFFFF
  #expect(state.buffer[8] == 0xFF)
  #expect(state.buffer[9] == 0xFF)

  try Primitive.Int16().encode(&state, Swift.Int16.max)
  // zigzag(Int16.max) = UInt16.max - 1 = 0xFFFE
  #expect(state.buffer[10] == 0xFE)
  #expect(state.buffer[11] == 0xFF)

  state.rewind()

  #expect(try Primitive.Int16().decode(&state) == 0)
  #expect(try Primitive.Int16().decode(&state) == -1)
  #expect(try Primitive.Int16().decode(&state) == 1)
  #expect(try Primitive.Int16().decode(&state) == -300)
  #expect(try Primitive.Int16().decode(&state) == Swift.Int16.min)
  #expect(try Primitive.Int16().decode(&state) == Swift.Int16.max)
}

@Test func testInt32() throws {
  var state = State()

  Primitive.Int32().preencode(&state, 0)
  Primitive.Int32().preencode(&state, -1)
  Primitive.Int32().preencode(&state, 1)
  Primitive.Int32().preencode(&state, -100_000)
  Primitive.Int32().preencode(&state, Swift.Int32.min)
  Primitive.Int32().preencode(&state, Swift.Int32.max)
  state.allocate()

  try Primitive.Int32().encode(&state, 0)
  // zigzag(0) = 0
  #expect(state.buffer[0] == 0x00)
  #expect(state.buffer[1] == 0x00)
  #expect(state.buffer[2] == 0x00)
  #expect(state.buffer[3] == 0x00)

  try Primitive.Int32().encode(&state, -1)
  // zigzag(-1) = 1
  #expect(state.buffer[4] == 0x01)
  #expect(state.buffer[5] == 0x00)
  #expect(state.buffer[6] == 0x00)
  #expect(state.buffer[7] == 0x00)

  try Primitive.Int32().encode(&state, 1)
  // zigzag(1) = 2
  #expect(state.buffer[8] == 0x02)
  #expect(state.buffer[9] == 0x00)
  #expect(state.buffer[10] == 0x00)
  #expect(state.buffer[11] == 0x00)

  try Primitive.Int32().encode(&state, -100_000)
  // zigzag(-100000) = 199999 = 0x00030D3F → LE: 0x3F 0x0D 0x03 0x00
  #expect(state.buffer[12] == 0x3F)
  #expect(state.buffer[13] == 0x0D)
  #expect(state.buffer[14] == 0x03)
  #expect(state.buffer[15] == 0x00)

  try Primitive.Int32().encode(&state, Swift.Int32.min)
  // zigzag(Int32.min) = UInt32.max = 0xFFFFFFFF
  #expect(state.buffer[16] == 0xFF)
  #expect(state.buffer[17] == 0xFF)
  #expect(state.buffer[18] == 0xFF)
  #expect(state.buffer[19] == 0xFF)

  try Primitive.Int32().encode(&state, Swift.Int32.max)
  // zigzag(Int32.max) = UInt32.max - 1 = 0xFFFFFFFE
  #expect(state.buffer[20] == 0xFE)
  #expect(state.buffer[21] == 0xFF)
  #expect(state.buffer[22] == 0xFF)
  #expect(state.buffer[23] == 0xFF)

  state.rewind()

  #expect(try Primitive.Int32().decode(&state) == 0)
  #expect(try Primitive.Int32().decode(&state) == -1)
  #expect(try Primitive.Int32().decode(&state) == 1)
  #expect(try Primitive.Int32().decode(&state) == -100_000)
  #expect(try Primitive.Int32().decode(&state) == Swift.Int32.min)
  #expect(try Primitive.Int32().decode(&state) == Swift.Int32.max)
}

@Test func testInt64() throws {
  var state = State()

  Primitive.Int64().preencode(&state, 0)
  Primitive.Int64().preencode(&state, -1)
  Primitive.Int64().preencode(&state, 1)
  Primitive.Int64().preencode(&state, -1_000_000_000)
  Primitive.Int64().preencode(&state, Swift.Int64.min)
  Primitive.Int64().preencode(&state, Swift.Int64.max)
  state.allocate()

  try Primitive.Int64().encode(&state, 0)
  // zigzag(0) = 0
  for i in 0..<8 {
    #expect(state.buffer[i] == 0x00)
  }

  try Primitive.Int64().encode(&state, -1)
  // zigzag(-1) = 1
  #expect(state.buffer[8] == 0x01)
  for i in 9..<16 {
    #expect(state.buffer[i] == 0x00)
  }

  try Primitive.Int64().encode(&state, 1)
  // zigzag(1) = 2
  #expect(state.buffer[16] == 0x02)
  for i in 17..<24 {
    #expect(state.buffer[i] == 0x00)
  }

  try Primitive.Int64().encode(&state, -1_000_000_000)
  // zigzag(-1_000_000_000) = 1_999_999_999 = 0x00000000_773593FF
  #expect(state.buffer[24] == 0xFF)
  #expect(state.buffer[25] == 0x93)
  #expect(state.buffer[26] == 0x35)
  #expect(state.buffer[27] == 0x77)
  for i in 28..<32 {
    #expect(state.buffer[i] == 0x00)
  }

  try Primitive.Int64().encode(&state, Swift.Int64.min)
  // zigzag(Int64.min) = UInt64.max = 0xFFFFFFFFFFFFFFFF
  for i in 32..<40 {
    #expect(state.buffer[i] == 0xFF)
  }

  try Primitive.Int64().encode(&state, Swift.Int64.max)
  // zigzag(Int64.max) = UInt64.max - 1 = 0xFFFFFFFFFFFFFFFE
  #expect(state.buffer[40] == 0xFE)
  for i in 41..<48 {
    #expect(state.buffer[i] == 0xFF)
  }

  state.rewind()

  #expect(try Primitive.Int64().decode(&state) == 0)
  #expect(try Primitive.Int64().decode(&state) == -1)
  #expect(try Primitive.Int64().decode(&state) == 1)
  #expect(try Primitive.Int64().decode(&state) == -1_000_000_000)
  #expect(try Primitive.Int64().decode(&state) == Swift.Int64.min)
  #expect(try Primitive.Int64().decode(&state) == Swift.Int64.max)
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

@Test func testInt() throws {
  var state = State()

  // zigzag: 0 → 0 (1 byte), -1 → 1 (1 byte), 1 → 2 (1 byte)
  Primitive.Int().preencode(&state, 0)
  #expect(state.end == 1)
  // zigzag(-200) = 399 → 3-byte varint (0xfd prefix + UInt16)
  Primitive.Int().preencode(&state, -200)
  #expect(state.end == 4)
  // zigzag(Int.max) = UInt.max - 1 → 9-byte varint (0xff prefix + UInt64)
  Primitive.Int().preencode(&state, Swift.Int.max)
  #expect(state.end == 13)
  Primitive.Int().preencode(&state, Swift.Int.min)
  #expect(state.end == 22)

  state.allocate()

  try Primitive.Int().encode(&state, 0)
  #expect(state.buffer[0] == 0)
  try Primitive.Int().encode(&state, -200)
  // zigzag(-200) = 399 = 0x018F → varint: 0xfd 0x8F 0x01
  #expect(state.buffer[1] == 0xfd)
  #expect(state.buffer[2] == 0x8F)
  #expect(state.buffer[3] == 0x01)
  try Primitive.Int().encode(&state, Swift.Int.max)
  // zigzag(Int.max) = UInt.max - 1 = 0xFFFFFFFFFFFFFFFE → 0xff prefix + 8 LE bytes
  #expect(state.buffer[4] == 0xff)
  #expect(state.buffer[5] == 0xFE)
  for i in 6..<12 {
    #expect(state.buffer[i] == 0xFF)
  }
  #expect(state.buffer[12] == 0xFF)

  try Primitive.Int().encode(&state, Swift.Int.min)
  // zigzag(Int.min) = UInt.max = 0xFFFFFFFFFFFFFFFF → 0xff prefix + 8 LE bytes
  #expect(state.buffer[13] == 0xff)
  for i in 14..<22 {
    #expect(state.buffer[i] == 0xFF)
  }

  state.rewind()

  #expect(try Primitive.Int().decode(&state) == 0)
  #expect(try Primitive.Int().decode(&state) == -200)
  #expect(try Primitive.Int().decode(&state) == Swift.Int.max)
  #expect(try Primitive.Int().decode(&state) == Swift.Int.min)
  #expect(state.start == state.end)
  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Int().decode(&state)
  }
}

@Test func testUIntEncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.UInt().encode(&state, 0xfd)
  }
}

@Test func testIntEncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Int().encode(&state, 127)
  }
}

@Test func testUInt8EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.UInt8().encode(&state, 1)
  }
}

@Test func testUInt8DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.UInt8().decode(&state)
  }
}

@Test func testUInt16EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.UInt16().encode(&state, 1)
  }
}

@Test func testUInt16DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.UInt16().decode(&state)
  }
}

@Test func testUInt32EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.UInt32().encode(&state, 1)
  }
}

@Test func testUInt32DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.UInt32().decode(&state)
  }
}

@Test func testUInt64EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.UInt64().encode(&state, 1)
  }
}

@Test func testUInt64DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.UInt64().decode(&state)
  }
}

@Test func testInt8EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Int8().encode(&state, 1)
  }
}

@Test func testInt8DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Int8().decode(&state)
  }
}

@Test func testInt16EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Int16().encode(&state, 1)
  }
}

@Test func testInt16DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Int16().decode(&state)
  }
}

@Test func testInt32EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Int32().encode(&state, 1)
  }
}

@Test func testInt32DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Int32().decode(&state)
  }
}

@Test func testInt64EncodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: EncodingError.outOfBounds) {
    try Primitive.Int64().encode(&state, 1)
  }
}

@Test func testInt64DecodeOutOfBounds() throws {
  var state = State()
  state.allocate()

  #expect(throws: DecodingError.outOfBounds) {
    try Primitive.Int64().decode(&state)
  }
}
