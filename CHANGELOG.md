# Changelog

## 1.0.0

First stable release.

- `Codec` protocol with top-level `encode` / `decode` helpers and a `State` buffer.
- Primitive codecs: fixed- and variable-width integers (zigzag for signed), `Bool`, `Float32` / `Float64`, `UTF8` strings, and `Buffer`.
- Container codecs: `Array`, `Record` (deterministic key order), `Frame` (length-prefixed), and deterministic `JSON`.
