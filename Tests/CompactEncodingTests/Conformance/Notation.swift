import Foundation

// CODECS.md writes a value as a token where JSON cannot hold it, as digits
// followed by `n` where it is an integer JSON spells ambiguously, and as
// lowercase hex where it is bytes. Both sides of a comparison land here.
enum Notation: Equatable {
  case absent
  case bool(Bool)
  case number(Double)
  case token(String)
  case wide(String)
  case text(String)
  case list([Notation])
  case record([String: Notation])
}

// The range a JSON number spells unambiguously, which is where the `n` suffix
// starts rather than what a double holds exactly.
private let spelled: ClosedRange<Int64> = -9_007_199_254_740_991...9_007_199_254_740_991

private let integerCategories: Set<String> = [
  "integers",
  "big-endian-integers",
  "big-integers",
]

extension Notation {
  static func integer(_ value: UInt64) -> Notation {
    value <= UInt64(spelled.upperBound) ? .number(Double(value)) : .wide(String(value))
  }

  static func integer(_ value: Int64) -> Notation {
    spelled.contains(value) ? .number(Double(value)) : .wide(String(value))
  }

  static func float(_ value: Double) -> Notation {
    if value.isNaN { return .token("NaN") }
    if value == .infinity { return .token("Infinity") }
    if value == -.infinity { return .token("-Infinity") }
    if value == 0 && value.sign == .minus { return .token("-0") }

    return .number(value)
  }

  static func bytes(_ value: Data) -> Notation {
    .text(hex(value))
  }

  static func read(_ json: JSONValue, category: String) -> Notation {
    switch json {
    case .null:
      return .absent
    case .bool(let value):
      return .bool(value)
    case .number(let value):
      return .number(value)
    case .string(let value):
      if ["NaN", "Infinity", "-Infinity", "-0"].contains(value) { return .token(value) }
      if integerCategories.contains(category), let digits = wideDigits(value) {
        return .wide(digits)
      }
      return .text(value)
    case .array(let values):
      return .list(values.map { read($0, category: category) })
    case .object(let members):
      return .record(members.mapValues { read($0, category: category) })
    }
  }
}

// The digits of an `n`-suffixed integer, or nil where the text is not one.
func wideDigits(_ text: String) -> String? {
  guard text.hasSuffix("n") else { return nil }

  let digits = String(text.dropLast())
  let unsigned = digits.hasPrefix("-") ? String(digits.dropFirst()) : digits

  guard !unsigned.isEmpty, unsigned.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }

  return digits
}

func hex(_ data: Data) -> String {
  data.map { String(format: "%02x", $0) }.joined()
}

func data(fromHex hex: String) -> Data? {
  guard hex.count % 2 == 0 else { return nil }

  var data = Data(capacity: hex.count / 2)
  var digits = Substring(hex)

  while !digits.isEmpty {
    guard let byte = UInt8(digits.prefix(2), radix: 16) else { return nil }
    data.append(byte)
    digits = digits.dropFirst(2)
  }

  return data
}
