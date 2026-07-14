Write a module `FrameParser` that parses a binary wire format into frames using binary pattern matching.

The wire format is a sequence of frames. Each frame is:

- 1 byte: frame type (unsigned integer)
- 2 bytes: payload length in bytes, big-endian unsigned
- N bytes: the payload

Implement `parse/1`:

- `parse(binary)` returns `{:ok, frames}` where `frames` is a list of `{type, payload}` tuples in wire order, with `type` an integer and `payload` a binary.
- The empty binary parses to `{:ok, []}`.
- If the data ends in the middle of a frame (header or payload), return `{:error, {:incomplete, bytes_remaining}}` where `bytes_remaining` is the number of unparsed bytes.

Also implement `encode/1`, the inverse: it takes a list of `{type, payload}` tuples and returns the wire binary. `encode/1` may assume payloads fit in 65535 bytes and types fit in one byte.

Round-tripping must hold: `parse(encode(frames)) == {:ok, frames}`.
