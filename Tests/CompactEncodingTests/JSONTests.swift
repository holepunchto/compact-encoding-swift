import Foundation
import Testing

@testable import CompactEncoding

@Test func testJSONObject() throws {
  var state = State()
  let input: Any = ["hello": "world"]

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)
  state.rewind()

  let decoded = try Primitive.JSON().decode(&state) as! [String: String]
  #expect(decoded == ["hello": "world"])
  #expect(state.start == state.end)
}

@Test func testJSONEmptyObject() throws {
  var state = State()
  let input: Any = [String: Any]()

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)
  state.rewind()

  let decoded = try Primitive.JSON().decode(&state) as! [String: Any]
  #expect(decoded.isEmpty)
  #expect(state.start == state.end)
}

@Test func testJSONNumber() throws {
  var state = State()
  let input: Any = 42

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)

  // varint(2) + "42"
  #expect(state.buffer[0] == 2)
  #expect(state.buffer[1] == 0x34)  // '4'
  #expect(state.buffer[2] == 0x32)  // '2'

  state.rewind()
  let decoded = try Primitive.JSON().decode(&state)
  #expect((decoded as? NSNumber)?.intValue == 42)
  #expect(state.start == state.end)
}

@Test func testJSONString() throws {
  var state = State()
  let input: Any = "hello"

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)

  // varint(7) + `"hello"` (with quotes)
  #expect(state.buffer[0] == 7)
  #expect(state.buffer[1] == 0x22)  // '"'
  #expect(state.buffer[2] == 0x68)  // 'h'
  #expect(state.buffer[6] == 0x6f)  // 'o'
  #expect(state.buffer[7] == 0x22)  // '"'

  state.rewind()
  let decoded = try Primitive.JSON().decode(&state) as! String
  #expect(decoded == "hello")
  #expect(state.start == state.end)
}

@Test func testJSONBool() throws {
  var state = State()
  let input: Any = true

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)

  // varint(4) + "true"
  #expect(state.buffer[0] == 4)
  #expect(state.buffer[1] == 0x74)  // 't'
  #expect(state.buffer[2] == 0x72)  // 'r'
  #expect(state.buffer[3] == 0x75)  // 'u'
  #expect(state.buffer[4] == 0x65)  // 'e'

  state.rewind()
  let decoded = try Primitive.JSON().decode(&state) as! Bool
  #expect(decoded == true)
  #expect(state.start == state.end)
}

@Test func testJSONArray() throws {
  var state = State()
  let input: Any = [1, 2, 3]

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)
  state.rewind()

  let decoded = try Primitive.JSON().decode(&state) as! [NSNumber]
  #expect(decoded.map(\.intValue) == [1, 2, 3])
  #expect(state.start == state.end)
}

@Test func testJSONEmptyArray() throws {
  var state = State()
  let input: Any = [Any]()

  Primitive.JSON().preencode(&state, input)
  state.allocate()
  try Primitive.JSON().encode(&state, input)
  state.rewind()

  let decoded = try Primitive.JSON().decode(&state) as! [Any]
  #expect(decoded.isEmpty)
  #expect(state.start == state.end)
}

@Test func testJSONObjectKeysSortedAndDeterministic() throws {
  // Keys given out of order must encode in sorted order, identically every run.
  let input: Any = ["banana": 1, "apple": 2]

  func encodeJSON(_ value: Any) throws -> Data {
    var state = State()
    Primitive.JSON().preencode(&state, value)
    state.allocate()
    try Primitive.JSON().encode(&state, value)
    return state.buffer
  }

  let first = try encodeJSON(input)
  let second = try encodeJSON(input)
  #expect(first == second)

  // The payload after the varint length prefix is canonical (keys sorted).
  var state = State(first)
  let payload = try Primitive.Buffer().decode(&state)
  #expect(Swift.String(decoding: payload, as: Swift.UTF8.self) == #"{"apple":2,"banana":1}"#)
}

@Test func testJSONDecodeInvalidJSON() throws {
  // Valid buffer length prefix but content is not valid JSON
  var state = State(Data([0x03, 0x58, 0x58, 0x58]))  // length=3, content="XXX"

  #expect(throws: (any Error).self) {
    _ = try Primitive.JSON().decode(&state)
  }
}
