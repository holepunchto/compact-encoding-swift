# compact-encoding-swift

Compact encoding schemes for Swift. The Swift counterpart of [compact-encoding](https://github.com/holepunchto/compact-encoding), and wire compatible with it.

```swift
dependencies: [
  .package(url: "https://github.com/holepunchto/compact-encoding-swift", from: "<tag>")
]

.product(name: "CompactEncoding", package: "compact-encoding-swift")
```

## Usage

Encode and decode a single value with the top-level `encode` and `decode` helpers:

```swift
import CompactEncoding

let data = try encode(Primitive.UInt(), 42)
let value = try decode(Primitive.UInt(), data)  // 42
```

To pack several values into one buffer, drive the `State` directly: `preencode` sizes the buffer, `allocate` reserves it, `encode` fills it, then `rewind` and `decode` read it back.

```swift
import CompactEncoding

var state = State()

Primitive.UInt().preencode(&state, 42)
Primitive.UTF8().preencode(&state, "hi")

state.allocate()

try Primitive.UInt().encode(&state, 42)
try Primitive.UTF8().encode(&state, "hi")

state.rewind()

let n = try Primitive.UInt().decode(&state)  // 42
let s = try Primitive.UTF8().decode(&state)  // "hi"
```

## Codecs

All codecs live under the `Primitive` namespace and conform to the `Codec` protocol.

| Codec                                                                     | Swift value                                             |
| ------------------------------------------------------------------------- | ------------------------------------------------------- |
| `Primitive.UInt`, `Primitive.UInt8/16/32/64`                              | unsigned integers (varint)                              |
| `Primitive.Int`, `Primitive.Int8/16/32/64`                                | signed integers (zigzag varint)                         |
| `Primitive.Bool`                                                          | `Bool`                                                  |
| `Primitive.Float32` (alias `Float`), `Primitive.Float64` (alias `Double`) | floating point                                          |
| `Primitive.UTF8` (alias `String`)                                         | `String`                                                |
| `Primitive.Buffer`                                                        | `Data`                                                  |
| `Primitive.Array(codec)`                                                  | `[Value]`                                               |
| `Primitive.Record(codec)`                                                 | `[String: Value]`, encoded with deterministic key order |
| `Primitive.Frame(codec)`                                                  | length-prefixed value                                   |
| `Primitive.JSON`                                                          | `Any`, encoded as deterministic JSON                    |

## Custom codecs

Conform to `Codec` to encode your own types. Implement `preencode` to size a value, `encode` to write it, and `decode` to read it back, all against the shared `State`:

```swift
struct Point { var x: UInt; var y: UInt }

struct PointCodec: Codec {
  func preencode(_ state: inout State, _ value: Point) {
    Primitive.UInt().preencode(&state, value.x)
    Primitive.UInt().preencode(&state, value.y)
  }

  func encode(_ state: inout State, _ value: Point) throws {
    try Primitive.UInt().encode(&state, value.x)
    try Primitive.UInt().encode(&state, value.y)
  }

  func decode(_ state: inout State) throws -> Point {
    Point(
      x: try Primitive.UInt().decode(&state),
      y: try Primitive.UInt().decode(&state)
    )
  }
}
```

## License

Apache-2.0
