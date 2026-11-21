import Foundation
import Testing

@testable import CompactEncoding

struct Divergence {
  let id: String
  let expected: Answer
  let given: Outcome
}

// `matched`, `diverged` and `unrun` partition the cases the corpus carries:
// every case lands in exactly one, so a codec the port does not provide cannot
// read as a passing one.
struct Capability {
  let codec: String
  let supported: Bool
  let reason: String?
  let matched: [String]
  let diverged: [Divergence]
  let unrun: [String]
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
        codec: name, supported: true, reason: file.reason, matched: [], diverged: [], unrun: [])
    }

    guard let subject = subjects[name] else {
      return Capability(
        codec: name, supported: false, reason: nil, matched: [], diverged: [],
        unrun: file.cases.map(\.id))
    }

    let answers = try Corpus.answers(name)

    var matched: [String] = []
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
        matched.append(example.id)
      } else {
        diverged.append(Divergence(id: example.id, expected: expected, given: given))
      }
    }

    return Capability(
      codec: name, supported: true, reason: nil, matched: matched, diverged: diverged, unrun: [])
  }
}

@Test func conformance() throws {
  let report = try run()

  let corpus = try Corpus.version()
  let json = try Report.json(report, corpus: corpus, implementation: "compact-encoding-swift")

  print(json)

  let diverged = report.flatMap(\.diverged)
  let accounted = report.reduce(0) { $0 + $1.matched.count + $1.diverged.count + $1.unrun.count }
  let carried = try Corpus.total()

  #expect(
    accounted == carried, "the report does not account for every case the corpus carries")
  #expect(diverged.isEmpty, "\(diverged.count) cases diverge from the corpus")
}
