func zigZagEncode(_ value: Int8) -> UInt8 {
  return UInt8(bitPattern: (value << 1) ^ (value >> 7))
}

func zigZagEncode(_ value: Int16) -> UInt16 {
  return UInt16(bitPattern: (value << 1) ^ (value >> 15))
}

func zigZagEncode(_ value: Int32) -> UInt32 {
  return UInt32(bitPattern: (value << 1) ^ (value >> 31))
}

func zigZagEncode(_ value: Int64) -> UInt64 {
  return UInt64(bitPattern: (value << 1) ^ (value >> 63))
}

func zigZagEncode(_ value: Int) -> UInt {
  return UInt(bitPattern: (value << 1) ^ (value >> (Int.bitWidth - 1)))
}

func zigZagDecode(_ value: UInt8) -> Int8 {
  return Int8(bitPattern: (value >> 1) ^ (0 &- (value & 1)))
}

func zigZagDecode(_ value: UInt16) -> Int16 {
  return Int16(bitPattern: (value >> 1) ^ (0 &- (value & 1)))
}

func zigZagDecode(_ value: UInt32) -> Int32 {
  return Int32(bitPattern: (value >> 1) ^ (0 &- (value & 1)))
}

func zigZagDecode(_ value: UInt64) -> Int64 {
  return Int64(bitPattern: (value >> 1) ^ (0 &- (value & 1)))
}

func zigZagDecode(_ value: UInt) -> Int {
  return Int(bitPattern: (value >> 1) ^ (0 &- (value & 1)))
}
