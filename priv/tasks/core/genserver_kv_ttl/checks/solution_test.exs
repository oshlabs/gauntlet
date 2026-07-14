defmodule TtlStoreTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, store} = TtlStore.start_link()
    %{store: store}
  end

  test "put then get", %{store: s} do
    assert :ok = TtlStore.put(s, :a, 1, 10_000)
    assert TtlStore.get(s, :a) == {:ok, 1}
  end

  test "missing key", %{store: s} do
    assert TtlStore.get(s, :nope) == :error
  end

  test "entry expires", %{store: s} do
    TtlStore.put(s, :a, 1, 30)
    assert TtlStore.get(s, :a) == {:ok, 1}
    Process.sleep(80)
    assert TtlStore.get(s, :a) == :error
  end

  test "expiry is active, not read-triggered", %{store: s} do
    TtlStore.put(s, :a, 1, 30)
    TtlStore.put(s, :b, 2, 10_000)
    Process.sleep(80)
    # :a must be gone from state without anyone reading it
    assert TtlStore.size(s) == 1
  end

  test "overwrite resets ttl", %{store: s} do
    TtlStore.put(s, :k, 1, 50)
    TtlStore.put(s, :k, 2, 10_000)
    Process.sleep(120)
    assert TtlStore.get(s, :k) == {:ok, 2}
  end

  test "overwrite replaces value immediately", %{store: s} do
    TtlStore.put(s, :k, 1, 10_000)
    TtlStore.put(s, :k, 2, 10_000)
    assert TtlStore.get(s, :k) == {:ok, 2}
    assert TtlStore.size(s) == 1
  end

  test "delete removes entry", %{store: s} do
    TtlStore.put(s, :k, 1, 10_000)
    assert :ok = TtlStore.delete(s, :k)
    assert TtlStore.get(s, :k) == :error
  end

  test "delete then reinsert survives the old timer", %{store: s} do
    TtlStore.put(s, :k, :old, 40)
    TtlStore.delete(s, :k)
    TtlStore.put(s, :k, :new, 10_000)
    Process.sleep(100)
    assert TtlStore.get(s, :k) == {:ok, :new}
  end

  test "supports named start", _ do
    {:ok, _pid} = TtlStore.start_link(name: :ttl_named_test)
    TtlStore.put(:ttl_named_test, :x, 42, 10_000)
    assert TtlStore.get(:ttl_named_test, :x) == {:ok, 42}
  end

  test "many entries, mixed expiry", %{store: s} do
    for i <- 1..50, do: TtlStore.put(s, {:short, i}, i, 30)
    for i <- 1..50, do: TtlStore.put(s, {:long, i}, i, 10_000)
    Process.sleep(100)
    assert TtlStore.size(s) == 50
    assert TtlStore.get(s, {:long, 7}) == {:ok, 7}
    assert TtlStore.get(s, {:short, 7}) == :error
  end
end
