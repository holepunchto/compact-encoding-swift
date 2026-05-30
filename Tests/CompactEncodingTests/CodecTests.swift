// Plain (non-@testable) import: this file only compiles if the convenience
// encode/decode functions — and the codecs they take — are public.
import CompactEncoding
import Foundation
import Testing

@Test func testTopLevelEncodeDecodeRoundTrip() throws {
  let data = try encode(Primitive.UInt(), 4200)
  #expect(data == Data([0xfd, 104, 16]))

  let value = try decode(Primitive.UInt(), data)
  #expect(value == 4200)
}

@Test func testTopLevelDecodeThrowsOnTruncatedInput() throws {
  // Length prefix says 5 bytes but only 3 follow.
  #expect(throws: DecodingError.outOfBounds) {
    _ = try decode(Primitive.UTF8(), Data([5, 0x68, 0x65, 0x6c]))
  }
}
