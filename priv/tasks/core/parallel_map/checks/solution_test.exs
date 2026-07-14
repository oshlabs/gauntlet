defmodule ParallelMapTest do
  use ExUnit.Case, async: true

  test "maps and preserves order" do
    result =
      ParallelMap.map([30, 10, 20], fn ms ->
        Process.sleep(ms)
        ms * 2
      end, max_concurrency: 3, timeout: 1_000)

    assert result == [{:ok, 60}, {:ok, 20}, {:ok, 40}]
  end

  test "empty list" do
    assert ParallelMap.map([], fn x -> x end, max_concurrency: 2, timeout: 100) == []
  end

  test "timeouts are isolated per element" do
    result =
      ParallelMap.map([1, 500, 1], fn ms ->
        Process.sleep(ms)
        ms
      end, max_concurrency: 3, timeout: 100)

    assert result == [{:ok, 1}, {:error, :timeout}, {:ok, 1}]
  end

  test "crashes are isolated per element" do
    result =
      ParallelMap.map([1, 2, 3], fn
        2 -> raise "boom"
        x -> x
      end, max_concurrency: 3, timeout: 1_000)

    assert result == [{:ok, 1}, {:error, :crashed}, {:ok, 3}]
  end

  test "exits are caught too" do
    result =
      ParallelMap.map([:a], fn _ -> exit(:bye) end, max_concurrency: 1, timeout: 1_000)

    assert result == [{:error, :crashed}]
  end

  test "caller survives and mailbox stays clean" do
    ParallelMap.map([1, 2], fn
      1 -> raise "boom"
      2 -> Process.sleep(500)
    end, max_concurrency: 2, timeout: 50)

    # No stray :DOWN / task messages may leak to the caller.
    refute_receive _, 200
  end

  test "respects max_concurrency" do
    {:ok, agent} = Agent.start_link(fn -> {0, 0} end)

    track = fn _ ->
      Agent.update(agent, fn {cur, max} -> {cur + 1, max(cur + 1, max)} end)
      Process.sleep(50)
      Agent.update(agent, fn {cur, max} -> {cur - 1, max} end)
      :done
    end

    ParallelMap.map(Enum.to_list(1..8), track, max_concurrency: 2, timeout: 5_000)

    {_, observed_max} = Agent.get(agent, & &1)
    assert observed_max <= 2
    assert observed_max > 0
  end

  test "timed-out workers are terminated" do
    test_pid = self()

    ParallelMap.map([:slow], fn _ ->
      test_pid |> send({:worker, self()})
      Process.sleep(10_000)
    end, max_concurrency: 1, timeout: 50)

    assert_receive {:worker, worker_pid}
    # give the implementation a moment to clean up
    Process.sleep(100)
    refute Process.alive?(worker_pid)
  end
end
