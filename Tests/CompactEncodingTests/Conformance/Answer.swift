import Foundation

// An answer is compared field by field. Equatable is synthesised over these six
// optionals, so the order the corpus happens to write its keys in cannot reach
// the comparison.
struct Answer: Equatable {
  var hex: String?
  var refused: Bool?
  var decodes: Notation?
  var read: Int?
  var bits: String?
  var rejects: Bool?

  static func read(_ json: JSONValue, category: String) -> Answer {
    guard case .object(let members) = json else { return Answer() }

    var answer = Answer()

    if case .string(let value)? = members["hex"] { answer.hex = value }
    if case .bool(let value)? = members["refused"] { answer.refused = value }
    if let value = members["decodes"] {
      answer.decodes = Notation.read(value, category: category)
    }
    if case .number(let value)? = members["read"] { answer.read = Int(value) }
    if case .string(let value)? = members["bits"] { answer.bits = value }
    if case .bool(let value)? = members["rejects"] { answer.rejects = value }

    return answer
  }
}

// `unrepresentable` is an outcome the port reports, never one the corpus
// commits, so it sits beside an answer rather than inside one.
enum Outcome: Equatable {
  case answer(Answer)
  case unrepresentable
}

// Why a corpus value never reached a codec. `unrepresentable` is for a value
// Swift's types cannot carry; `refused` is the port declining a value it could
// have been handed, and reads as an ordinary refusal.
enum Boundary: Error {
  case unrepresentable
  case refused
}

func conformant(
  _ given: Outcome,
  rules: [String],
  answer: Answer,
  alternatives: [Answer],
  unrepresentable: Set<String>
) -> Bool {
  switch given {
  case .unrepresentable:
    return rules.contains(where: unrepresentable.contains)
  case .answer(let given):
    return given == answer || alternatives.contains(given)
  }
}
