defmodule CounterFarmTest do
  use ExUnit.Case

  setup do
    start_supervised!(CounterFarm)
    :ok
  end

  test "incr starts counters on demand" do
    assert CounterFarm.incr(:a) == 1
    assert CounterFarm.incr(:a) == 2
    assert CounterFarm.incr(:b) == 1
  end

  test "value of unknown id is 0" do
    assert CounterFarm.value(:unknown) == 0
  end

  test "value reflects increments" do
    CounterFarm.incr(:v)
    CounterFarm.incr(:v)
    assert CounterFarm.value(:v) == 2
  end

  test "arbitrary terms as ids" do
    assert CounterFarm.incr({:user, 42}) == 1
    assert CounterFarm.incr("string-id") == 1
    assert CounterFarm.value({:user, 42}) == 1
  end

  test "which finds the process" do
    CounterFarm.incr(:w)
    assert {:ok, pid} = CounterFarm.which(:w)
    assert Process.alive?(pid)
    assert CounterFarm.which(:missing) == :error
  end

  test "count tracks distinct ids" do
    assert CounterFarm.count() == 0
    CounterFarm.incr(:x)
    CounterFarm.incr(:x)
    CounterFarm.incr(:y)
    assert CounterFarm.count() == 2
  end

  test "counters are separate processes" do
    CounterFarm.incr(:p1)
    CounterFarm.incr(:p2)
    {:ok, pid1} = CounterFarm.which(:p1)
    {:ok, pid2} = CounterFarm.which(:p2)
    assert pid1 != pid2
  end

  test "concurrent first-touch increments on one id are all counted" do
    n = 50

    1..n
    |> Task.async_stream(fn _ -> CounterFarm.incr(:race) end, max_concurrency: n)
    |> Enum.to_list()

    assert CounterFarm.value(:race) == n
    assert {:ok, _} = CounterFarm.which(:race)
    assert CounterFarm.count() == 1
  end
end
