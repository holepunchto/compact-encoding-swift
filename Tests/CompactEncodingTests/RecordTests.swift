import Testing

@testable import CompactEncoding

@Test func testRecordUInt() throws {
  var state = State()

  let input: [String: Swift.UInt] = ["alice": 10, "bob": 20]

  Primitive.Record(Primitive.UInt()).preencode(&state, input)
  state.allocate()

  try Primitive.Record(Primitive.UInt()).encode(&state, input)

  state.rewind()

  let decoded = try Primitive.Record(Primitive.UInt()).decode(&state)
  #expect(decoded["alice"] == 10)
  #expect(decoded["bob"] == 20)
  #expect(decoded.count == 2)
}

@Test func testRecordSortedEncoding() throws {
  // Keys must be sorted alphabetically — canonical byte order
  var state = State()

  let input: [String: Swift.UInt] = ["foo": 100, "bar": 200, "baz": 300]

  Primitive.Record(Primitive.UInt()).preencode(&state, input)
  state.allocate()

  try Primitive.Record(Primitive.UInt()).encode(&state, input)

  // Canonical bytes from hyperschema-test fixture 23:
  // bar(200), baz(300), foo(100) — alphabetical order
  let expected: [UInt8] = [
    0x03,  // count = 3
    0x03, 0x62, 0x61, 0x72,  // "bar"
    0xc8,  // 200
    0x03, 0x62, 0x61, 0x7a,  // "baz"
    0xfd, 0x2c, 0x01,  // 300
    0x03, 0x66, 0x6f, 0x6f,  // "foo"
    0x64  // 100
  ]
  #expect(Swift.Array(state.buffer) == expected)
}

@Test func testRecordEmpty() throws {
  var state = State()

  let input: [String: Swift.UInt] = [:]

  Primitive.Record(Primitive.UInt()).preencode(&state, input)
  state.allocate()

  try Primitive.Record(Primitive.UInt()).encode(&state, input)
  #expect(state.buffer[0] == 0)

  state.rewind()

  let decoded = try Primitive.Record(Primitive.UInt()).decode(&state)
  #expect(decoded.isEmpty)
}

@Test func testRecordString() throws {
  var state = State()

  let input: [String: String] = ["greeting": "hello", "farewell": "bye"]

  Primitive.Record(Primitive.UTF8()).preencode(&state, input)
  state.allocate()

  try Primitive.Record(Primitive.UTF8()).encode(&state, input)

  state.rewind()

  let decoded = try Primitive.Record(Primitive.UTF8()).decode(&state)
  #expect(decoded["greeting"] == "hello")
  #expect(decoded["farewell"] == "bye")
  #expect(decoded.count == 2)
}
