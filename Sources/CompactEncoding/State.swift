import Foundation

public struct State {
  public var start = 0
  public var end = 0
  public var buffer: Data = Data()

  public init() {}

  public init(_ buffer: Data) {
    self.end = buffer.count
    self.buffer = buffer
  }

  public mutating func allocate() {
    self.buffer = Data(count: self.end)
  }

  public mutating func rewind() {
    self.start = 0
  }
}
