defmodule BitSetTest do
  use ExUnit.Case, async: true

  test "new and to_list ascending" do
    assert BitSet.new([5, 1, 3]) |> Enum.to_list() == [1, 3, 5]
  end

  test "duplicates collapse" do
    assert BitSet.new([2, 2, 2]) |> Enum.to_list() == [2]
  end

  test "empty set" do
    assert BitSet.new() |> Enum.to_list() == []
    assert BitSet.new() |> Enum.count() == 0
  end

  test "put and member?" do
    set = BitSet.new() |> BitSet.put(7) |> BitSet.put(0)
    assert BitSet.member?(set, 7)
    assert BitSet.member?(set, 0)
    refute BitSet.member?(set, 3)
  end

  test "count" do
    assert BitSet.new([1, 2, 3, 100]) |> Enum.count() == 4
  end

  test "in operator uses the protocol" do
    assert 5 in BitSet.new([5])
    refute 6 in BitSet.new([5])
  end

  test "Enum functions work" do
    set = BitSet.new([1, 2, 3, 4])
    assert Enum.map(set, &(&1 * 10)) == [10, 20, 30, 40]
    assert Enum.sum(set) == 10
    assert Enum.filter(set, &(rem(&1, 2) == 0)) == [2, 4]
  end

  test "take halts early on a large set" do
    set = BitSet.new(0..100_000)

    {microseconds, result} = :timer.tc(fn -> Enum.take(set, 3) end)
    assert result == [0, 1, 2]
    # generous bound: halting implementations finish far under this,
    # full iteration of 100k members does not
    assert microseconds < 100_000
  end

  test "count does not reduce" do
    # A count/1 implemented via the reduce fallback returns {:error, module};
    # a real one returns {:ok, n}.
    set = BitSet.new([1, 5, 9])
    assert Enumerable.count(set) == {:ok, 3}
  end

  test "member? does not reduce" do
    set = BitSet.new([4])
    assert Enumerable.member?(set, 4) == {:ok, true}
    assert Enumerable.member?(set, 5) == {:ok, false}
  end
end
