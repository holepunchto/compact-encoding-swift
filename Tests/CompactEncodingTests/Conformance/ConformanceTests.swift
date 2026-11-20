import Foundation
import Testing

@testable import CompactEncoding

struct Divergence {
  let id: String
  let expected: Answer
  let given: Outcome
}

struct Capability {
  let codec: String
  let supported: Bool
  let reason: String?
  let total: Int
  let matched: Int
  let diverged: [Divergence]
}

// A case asks one of two questions: `value` asks what it encodes to, `bytes`
// ask what a decoder makes of them.
func answered(_ subject: Subject, _ example: Example) -> Outcome {
  if let bytes = example.input.bytes {
    guard let input = data(fromHex: bytes) else { return .answer(Answer(rejects: true)) }

    do {
      let (value, read, bits) = try subject.decode(input)
      return .answer(Answer(decodes: value, read: read, bits: bits))
    } catch {
      return .answer(Answer(rejects: true))
    }
  }

  guard let value = example.input.value else { return .answer(Answer()) }

  do {
    let encoded = try subject.encode(value)
    return .answer(Answer(hex: encoded))
  } catch Boundary.unrepresentable {
    return .unrepresentable
  } catch {
    return .answer(Answer(refused: true))
  }
}

func run() throws -> [Capability] {
  guard Corpus.present() else { throw MissingCorpus() }

  let unrepresentable = try Corpus.unrepresentable()
  let subjects = Subjects.make()

  return try Corpus.codecs().map { name in
    let file = try Corpus.cases(name)

    // A codec with no cases is carried as a capability all the same, with the
    // corpus's own reason for not covering it.
    guard !file.cases.isEmpty else {
      return Capability(
        codec: name, supported: true, reason: file.reason, total: 0, matched: 0, diverged: [])
    }

    guard let subject = subjects[name] else {
      return Capability(
        codec: name, supported: false, reason: nil, total: file.cases.count, matched: 0,
        diverged: [])
    }

    let answers = try Corpus.answers(name)

    var matched = 0
    var diverged: [Divergence] = []

    for example in file.cases {
      let expected = Answer.read(answers[example.id] ?? .null, category: file.category)
      let alternatives = (example.alternatives ?? []).map {
        Answer.read($0, category: file.category)
      }
      let given = answered(subject, example)

      if conformant(
        given,
        rules: example.rules,
        answer: expected,
        alternatives: alternatives,
        unrepresentable: unrepresentable
      ) {
        matched += 1
      } else {
        diverged.append(Divergence(id: example.id, expected: expected, given: given))
      }
    }

    return Capability(
      codec: name, supported: true, reason: nil, total: file.cases.count, matched: matched,
      diverged: diverged)
  }
}

@Test func conformance() throws {
  let report = try run()

  let covered = report.filter { $0.supported && $0.total > 0 }
  let unsupported = report.filter { !$0.supported }
  let uncovered = report.filter { $0.supported && $0.total == 0 }

  let matched = report.reduce(0) { $0 + $1.matched }
  let diverged = report.flatMap(\.diverged)
  let skipped = unsupported.reduce(0) { $0 + $1.total }

  for capability in covered {
    let mark = capability.diverged.isEmpty ? "ok  " : "FAIL"
    print("  \(mark) \(capability.codec.padded(to: 26)) \(capability.matched)/\(capability.total)")
  }

  print("\nnot provided by this package:")
  for capability in unsupported {
    print("  -    \(capability.codec.padded(to: 26)) \(capability.total) cases skipped")
  }

  print("\nno cases in the corpus: \(uncovered.count) codecs")

  for divergence in diverged {
    print("DIVERGES \(divergence.id)")
    print("  corpus: \(divergence.expected)")
    print("  port:   \(divergence.given)")
  }

  print(
    "\n\(matched) cases matched, \(diverged.count) diverged, "
      + "\(skipped) skipped as unsupported")

  #expect(diverged.isEmpty, "\(diverged.count) cases diverge from the corpus")
}

extension String {
  fileprivate func padded(to width: Int) -> String {
    count >= width ? self : self + String(repeating: " ", count: width - count)
  }
}
