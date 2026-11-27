import Foundation

@testable import CompactEncoding

// A codec under test, with its value type erased so the runner can drive every
// capability through one shape. Each Swift codec names the type it carries, so
// turning a corpus value into one is where `unrepresentable` is decided.
struct Subject {
  let encode: (JSONValue) throws -> String
  let decode: (Data) throws -> (value: Notation, read: Int, bits: String?)
}

func subject<C: Codec>(
  _ codec: C,
  taking read: @escaping (JSONValue) throws -> C.Value,
  showing show: @escaping (C.Value) -> Notation,
  bits rewritten: @escaping (C.Value) -> Bool = { _ in false }
) -> Subject {
  Subject(
    encode: { json in
      let value = try read(json)
      let encoded = try CompactEncoding.encode(codec, value)

      return hex(encoded)
    },
    decode: { data in
      var state = State(data)
      let value = try codec.decode(&state)
      var bits: String?

      if rewritten(value) {
        bits = hex(try CompactEncoding.encode(codec, value))
      }

      return (value: show(value), read: state.start, bits: bits)
    }
  )
}

// A corpus directory is named for the codec it covers, and the `codec`
// declaration beside the cases says how a built one is assembled. Swift builds
// its codecs at compile time, so the name is what this registry keys on.
enum Subjects {
  static func make() -> [String: Subject] {
    let buffer = subject(Primitive.Buffer(), taking: binary, showing: { .bytes($0) })

    // The port exports one record codec, which sorts its keys, so it answers
    // for the corpus's record and orderedRecord both.
    let record = subject(
      Primitive.Record(Primitive.UInt()),
      taking: { json in
        guard case .array(let pairs) = json else { throw Boundary.unrepresentable }

        var value: [String: UInt] = [:]

        for pair in pairs {
          guard case .array(let both) = pair, both.count == 2 else {
            throw Boundary.unrepresentable
          }
          value[try text(both[0])] = try whole(both[1], as: UInt.self)
        }

        return value
      },
      showing: { pairs in .record(pairs.mapValues { .integer(UInt64($0)) }) }
    )

    // Assigned a statement at a time: one literal of twenty entries is a single
    // expression for the type checker, and each entry names a different Value.
    var all: [String: Subject] = [:]

    all["bool"] = subject(Primitive.Bool(), taking: boolean, showing: { .bool($0) })
    all["buffer"] = buffer
    all["uint8array"] = buffer
    all["utf8"] = subject(Primitive.UTF8(), taking: text, showing: { .text($0) })
    all["raw"] = subject(Primitive.Raw(), taking: binary, showing: { .bytes($0) })
    all["optionalBuffer"] = subject(
      Primitive.OptionalBuffer(),
      taking: optionalBinary,
      showing: { data in data.map { Notation.bytes($0) } ?? .absent }
    )

    for size in [3, 8, 16, 24, 32, 64] {
      all["fixed-\(size)"] = subject(
        Primitive.Fixed(size), taking: binary, showing: { .bytes($0) })
    }

    all["float32"] = subject(
      Primitive.Float32(),
      taking: { try Float(real($0)) },
      showing: { .float(Double($0)) },
      bits: { $0.isNaN }
    )
    all["float64"] = subject(
      Primitive.Float64(),
      taking: real,
      showing: { .float($0) },
      bits: { $0.isNaN }
    )

    all["uint8"] = unsigned(Primitive.UInt8())
    all["uint16"] = unsigned(Primitive.UInt16())
    all["uint32"] = unsigned(Primitive.UInt32())
    all["uint64"] = unsigned(Primitive.UInt64())
    all["uint"] = unsigned(Primitive.UInt())

    all["int8"] = signed(Primitive.Int8())
    all["int16"] = signed(Primitive.Int16())
    all["int32"] = signed(Primitive.Int32())
    all["int64"] = signed(Primitive.Int64())
    all["int"] = signed(Primitive.Int())

    all["array-uint"] = subject(
      Primitive.Array(Primitive.UInt()),
      taking: { json in
        guard case .array(let elements) = json else { throw Boundary.unrepresentable }
        return try elements.map { try whole($0, as: UInt.self) }
      },
      showing: { elements in .list(elements.map { .integer(UInt64($0)) }) }
    )
    all["frame-uint"] = subject(
      Primitive.Frame(Primitive.UInt()),
      taking: { try whole($0, as: UInt.self) },
      showing: { .integer(UInt64($0)) }
    )
    all["record-utf8-uint"] = record
    all["orderedRecord-utf8-uint"] = record

    return all
  }

  private static func unsigned<C: Codec>(_ codec: C) -> Subject
  where C.Value: FixedWidthInteger & UnsignedInteger {
    subject(
      codec,
      taking: { try whole($0, as: C.Value.self) },
      showing: { .integer(UInt64($0)) }
    )
  }

  private static func signed<C: Codec>(_ codec: C) -> Subject
  where C.Value: FixedWidthInteger & SignedInteger {
    subject(
      codec,
      taking: { try whole($0, as: C.Value.self) },
      showing: { .integer(Int64($0)) }
    )
  }
}

// An integer the codec's own type carries. A fraction, a negative through an
// unsigned codec and a value past the width all fail the same conversion, which
// is what `unrepresentable` names: the port cannot be handed the value in order
// to refuse it. A bare JSON number is read through a double, the spelling the
// corpus wrote it in, so an integer past the range JSON spells unambiguously
// reads back as the double it names.
func whole<T: FixedWidthInteger>(_ json: JSONValue, as type: T.Type) throws -> T {
  switch json {
  case .number(let value):
    guard let integer = T(exactly: value) else { throw Boundary.unrepresentable }
    return integer
  case .string(let value):
    guard let digits = wideDigits(value) else { throw Boundary.unrepresentable }

    if digits.hasPrefix("-") {
      guard let wide = Int64(digits), let integer = T(exactly: wide) else {
        throw Boundary.unrepresentable
      }
      return integer
    }

    guard let wide = UInt64(digits), let integer = T(exactly: wide) else {
      throw Boundary.unrepresentable
    }
    return integer
  default:
    throw Boundary.unrepresentable
  }
}

func real(_ json: JSONValue) throws -> Double {
  switch json {
  case .number(let value):
    return value
  case .string("NaN"):
    return .nan
  case .string("Infinity"):
    return .infinity
  case .string("-Infinity"):
    return -.infinity
  case .string("-0"):
    return -0.0
  default:
    throw Boundary.unrepresentable
  }
}

func boolean(_ json: JSONValue) throws -> Bool {
  guard case .bool(let value) = json else { throw Boundary.unrepresentable }
  return value
}

func binary(_ json: JSONValue) throws -> Data {
  guard case .string(let value) = json, let decoded = data(fromHex: value) else {
    throw Boundary.unrepresentable
  }
  return decoded
}

func optionalBinary(_ json: JSONValue) throws -> Data? {
  if case .null = json { return nil }

  return try binary(json)
}

// Swift's String holds well-formed Unicode text, so a case naming an unpaired
// surrogate names a value the port's text type cannot carry. The codec never
// sees it, which reads as a refusal: `utf8-replaces-unpaired-surrogate` is
// delegated rather than unrepresentable, and commits that refusal as the
// alternative answer beside the replacement bytes.
func text(_ json: JSONValue) throws -> String {
  switch json {
  case .string(let value):
    return value
  case .object(let members):
    guard case .array(let units)? = members["units"] else { throw Boundary.unrepresentable }

    let codeUnits = try units.map { try whole($0, as: UInt16.self) }

    guard paired(codeUnits) else { throw Boundary.refused }

    return String(decoding: codeUnits, as: UTF16.self)
  default:
    throw Boundary.unrepresentable
  }
}

private func paired(_ units: [UInt16]) -> Bool {
  var index = units.startIndex

  while index < units.endIndex {
    switch units[index] {
    case 0xd800...0xdbff:
      let next = units.index(after: index)
      guard next < units.endIndex, (0xdc00...0xdfff).contains(units[next]) else { return false }
      index = units.index(after: next)
    case 0xdc00...0xdfff:
      return false
    default:
      index = units.index(after: index)
    }
  }

  return true
}
