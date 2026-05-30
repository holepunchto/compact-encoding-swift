import Foundation

public struct State {
  public var start = 0
  public var end = 0
  public var remaining: Int {
    return self.end - self.start
  }
  public var buffer: Data = Data()

  public init() {}

  public init(_ buffer: Data) {
    // A Data slice keeps its parent's indices (buffer[10...] starts at 10), but
    // the codecs index from start = 0. Re-base so buffer[0] is always valid.
    self.buffer = Data(buffer)
    self.end = self.buffer.count
  }

  public mutating func allocate() {
    self.buffer = Data(count: self.end)
  }

  public mutating func rewind() {
    self.start = 0
  }
}
