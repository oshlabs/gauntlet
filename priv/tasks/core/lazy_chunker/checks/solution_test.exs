defmodule LazyChunkerTest do
  use ExUnit.Case, async: true

  test "chunks by budget" do
    assert LazyChunker.by_budget([1, 2, 3, 4, 5], 5) |> Enum.to_list() ==
             [[1, 2], [3], [4], [5]]
  end

  test "exact fits" do
    assert LazyChunker.by_budget([2, 3, 5, 1, 4], 5) |> Enum.to_list() ==
             [[2, 3], [5], [1, 4]]
  end

  test "oversized element forms its own chunk" do
    assert LazyChunker.by_budget([9, 1, 1], 5) |> Enum.to_list() == [[9], [1, 1]]
  end

  test "oversized element mid-stream closes the open chunk first" do
    assert LazyChunker.by_budget([1, 9, 1], 5) |> Enum.to_list() == [[1], [9], [1]]
  end

  test "empty input yields no chunks" do
    assert LazyChunker.by_budget([], 5) |> Enum.to_list() == []
  end

  test "zeros accumulate into one chunk" do
    assert LazyChunker.by_budget([0, 0, 0], 5) |> Enum.to_list() == [[0, 0, 0]]
  end

  test "is lazy on infinite input" do
    result =
      Stream.cycle([2])
      |> LazyChunker.by_budget(6)
      |> Enum.take(2)

    assert result == [[2, 2, 2], [2, 2, 2]]
  end

  test "does not force the tail of the source" do
    # A source that raises past element 6; taking 2 chunks must not touch it.
    source =
      Stream.unfold(0, fn
        n when n < 6 -> {1, n + 1}
        _ -> raise "source forced too far"
      end)

    assert source |> LazyChunker.by_budget(2) |> Enum.take(2) == [[1, 1], [1, 1]]
  end
end
