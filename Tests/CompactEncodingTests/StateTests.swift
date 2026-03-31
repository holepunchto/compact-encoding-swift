import Foundation
import Testing

@testable import CompactEncoding

@Test func testStateDefaultInit() {
  let state = State()

  #expect(state.start == 0)
  #expect(state.end == 0)
  #expect(state.buffer == Data())
}

@Test func testStateBufferInit() {
  let data = Data([0x01, 0x02, 0x03])
  let state = State(data)

  #expect(state.start == 0)
  #expect(state.end == 3)
  #expect(state.buffer == data)
}

@Test func testStateBufferInitEmpty() {
  let state = State(Data())

  #expect(state.start == 0)
  #expect(state.end == 0)
  #expect(state.buffer == Data())
}

@Test func testStateRemaining() {
  var state = State(Data([0x01, 0x02, 0x03, 0x04, 0x05]))

  #expect(state.remaining == 5)

  state.start = 2
  #expect(state.remaining == 3)

  state.start = 5
  #expect(state.remaining == 0)
}

@Test func testStateAllocate() {
  var state = State()

  state.end = 10
  state.allocate()

  #expect(state.buffer.count == 10)
  #expect(state.buffer == Data(count: 10))
}

@Test func testStateAllocateZero() {
  var state = State()

  state.allocate()

  #expect(state.buffer.count == 0)
  #expect(state.buffer == Data())
}

@Test func testStateRewind() {
  var state = State()

  state.start = 42
  state.rewind()

  #expect(state.start == 0)
}

@Test func testStateRewindPreservesEnd() {
  var state = State()

  state.end = 10
  state.start = 5
  state.rewind()

  #expect(state.start == 0)
  #expect(state.end == 10)
}
