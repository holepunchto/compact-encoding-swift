import Foundation

// The report CONFORMANCE.md defines, the same shape in every language so that
// two ports diff rather than get read side by side.
enum Report {
  static func json(_ capabilities: [Capability], corpus: String, implementation: String) throws
    -> String
  {
    let covered = capabilities.filter { $0.supported }
    let unsupported = capabilities.filter { !$0.supported }
    let uncovered = capabilities.filter { $0.reason != nil }

    let matched = covered.flatMap(\.matched).sorted()
    let diverged = covered.flatMap(\.diverged)
    let unrun = unsupported.flatMap(\.unrun).sorted()

    let document: [String: Any] = [
      "corpus": corpus,
      "implementation": implementation,
      "summary": [
        "matched": matched.count,
        "diverged": diverged.count,
        "unrun": unrun.count,
        "unsupported": unsupported.count,
        "uncovered": uncovered.count,
      ],
      "unsupported": unsupported.map(\.codec).sorted(),
      "uncovered": Dictionary(
        uniqueKeysWithValues: uncovered.map { ($0.codec, $0.reason ?? "") }),
      "diverged": Dictionary(
        uniqueKeysWithValues: diverged.map {
          ($0.id, ["corpus": encoded($0.expected), "port": encoded($0.given)])
        }),
      "unrun": unrun,
      "matched": matched,
    ]

    let data = try JSONSerialization.data(
      withJSONObject: document, options: [.prettyPrinted, .sortedKeys])

    return String(decoding: data, as: UTF8.self)
  }

  // `unrepresentable` is an outcome rather than an answer, so it is reported as
  // its own flag beside the ones an answer carries.
  private static func encoded(_ outcome: Outcome) -> [String: Any] {
    switch outcome {
    case .unrepresentable:
      return ["unrepresentable": true]
    case .answer(let answer):
      return encoded(answer)
    }
  }

  private static func encoded(_ answer: Answer) -> [String: Any] {
    var out: [String: Any] = [:]

    if let hex = answer.hex { out["hex"] = hex }
    if let refused = answer.refused { out["refused"] = refused }
    if let decodes = answer.decodes { out["decodes"] = encoded(decodes) }
    if let read = answer.read { out["read"] = read }
    if let bits = answer.bits { out["bits"] = bits }
    if let rejects = answer.rejects { out["rejects"] = rejects }

    return out
  }

  private static func encoded(_ notation: Notation) -> Any {
    switch notation {
    case .absent:
      return NSNull()
    case .bool(let value):
      return value
    case .number(let value):
      return value
    case .token(let value):
      return value
    case .wide(let digits):
      return digits + "n"
    case .text(let value):
      return value
    case .list(let values):
      return values.map { encoded($0) }
    case .record(let members):
      return members.mapValues { encoded($0) }
    }
  }
}
