import Foundation

// The corpus is resolved as an npm dev dependency rather than vendored, so a
// case added upstream arrives through the pin in package.json.
enum Corpus {
  static let root: URL = {
    if let override = ProcessInfo.processInfo.environment["COMPACT_ENCODING_CORPUS"] {
      return URL(fileURLWithPath: override)
    }

    return URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()  // Conformance
      .deletingLastPathComponent()  // CompactEncodingTests
      .deletingLastPathComponent()  // Tests
      .deletingLastPathComponent()  // repository root
      .appendingPathComponent("node_modules")
      .appendingPathComponent("compact-encoding-test")
  }()

  static var fixtures: URL {
    root.appendingPathComponent("fixtures")
  }

  static func present() -> Bool {
    FileManager.default.fileExists(atPath: fixtures.path)
  }

  static func codecs() throws -> [String] {
    try FileManager.default
      .contentsOfDirectory(at: fixtures, includingPropertiesForKeys: [.isDirectoryKey])
      .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }
      .map { $0.lastPathComponent }
      .sorted()
  }

  static func unrepresentable() throws -> Set<String> {
    Set(try load([String].self, from: fixtures.appendingPathComponent("unrepresentable.json")))
  }

  static func cases(_ codec: String) throws -> CaseFile {
    try load(CaseFile.self, from: fixtures.appendingPathComponent(codec + "/cases.json"))
  }

  static func answers(_ codec: String) throws -> [String: JSONValue] {
    let url = fixtures.appendingPathComponent(codec + "/answers.json")

    return try load([String: JSONValue].self, from: url)
  }

  private static func load<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
    try JSONDecoder().decode(type, from: Data(contentsOf: url))
  }
}

struct CaseFile: Decodable {
  let category: String
  let reason: String?
  let cases: [Example]
}

struct Example: Decodable {
  let id: String
  let rules: [String]
  let input: Input
  let alternatives: [JSONValue]?
}

struct Input: Decodable {
  let value: JSONValue?
  let bytes: String?

  private enum CodingKeys: String, CodingKey {
    case value
    case bytes
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // An absent `value` and a `value` of null are different questions, so this
    // asks whether the key is there rather than letting null collapse into nil.
    self.value =
      container.contains(.value) ? try container.decode(JSONValue.self, forKey: .value) : nil
    self.bytes = try container.decodeIfPresent(String.self, forKey: .bytes)
  }
}

enum JSONValue: Decodable {
  case null
  case bool(Bool)
  case number(Double)
  case string(String)
  case array([JSONValue])
  case object([String: JSONValue])

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self = .null
    } else if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
    } else if let number = try? container.decode(Double.self) {
      self = .number(number)
    } else if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let array = try? container.decode([JSONValue].self) {
      self = .array(array)
    } else {
      self = .object(try container.decode([String: JSONValue].self))
    }
  }
}

struct MissingCorpus: Error, CustomStringConvertible {
  var description: String {
    "No corpus under \(Corpus.root.path). Run npm install."
  }
}
