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
  let decoded = try Primitive.JSON().decode(&state) as! Int
  #expect(decoded == 42)
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

  let decoded = try Primitive.JSON().decode(&state) as! [Int]
  #expect(decoded == [1, 2, 3])
  #expect(state.start == state.end)
}
