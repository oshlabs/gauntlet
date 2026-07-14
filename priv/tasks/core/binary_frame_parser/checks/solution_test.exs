defmodule FrameParserTest do
  use ExUnit.Case, async: true

  test "empty binary" do
    assert FrameParser.parse(<<>>) == {:ok, []}
  end

  test "single frame" do
    assert FrameParser.parse(<<7, 0, 5, "hello">>) == {:ok, [{7, "hello"}]}
  end

  test "empty payload frame" do
    assert FrameParser.parse(<<1, 0, 0>>) == {:ok, [{1, ""}]}
  end

  test "multiple frames in order" do
    wire = <<1, 0, 2, "ab", 2, 0, 0, 3, 0, 1, "z">>
    assert FrameParser.parse(wire) == {:ok, [{1, "ab"}, {2, ""}, {3, "z"}]}
  end

  test "incomplete header" do
    assert FrameParser.parse(<<1, 0>>) == {:error, {:incomplete, 2}}
  end

  test "incomplete payload" do
    assert FrameParser.parse(<<1, 0, 5, "abc">>) == {:error, {:incomplete, 6}}
  end

  test "incomplete after valid frames" do
    wire = <<1, 0, 1, "x", 9>>
    assert FrameParser.parse(wire) == {:error, {:incomplete, 1}}
  end

  test "binary (non-utf8) payloads survive" do
    payload = <<0, 255, 128, 1>>
    assert FrameParser.parse(<<42, 0, 4, payload::binary>>) == {:ok, [{42, payload}]}
  end

  test "encode single" do
    assert FrameParser.encode([{7, "hi"}]) == <<7, 0, 2, "hi">>
  end

  test "encode empty list" do
    assert FrameParser.encode([]) == <<>>
  end

  test "round trip" do
    frames = [{0, ""}, {255, :binary.copy(<<170>>, 300)}, {9, "mixed"}]
    assert FrameParser.parse(FrameParser.encode(frames)) == {:ok, frames}
  end

  test "length is big-endian" do
    frames = [{1, :binary.copy(<<7>>, 258)}]
    assert <<1, 1, 2, _::binary>> = FrameParser.encode(frames)
  end
end
