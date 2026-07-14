defmodule Gauntlet.LimiterTest do
  use ExUnit.Case, async: true

  alias Gauntlet.Limiter

  test "caps concurrency" do
    {:ok, limiter} = Limiter.start_link(count: 2)
    {:ok, agent} = Agent.start_link(fn -> {0, 0} end)

    1..10
    |> Task.async_stream(
      fn _ ->
        Limiter.with_slot(limiter, fn ->
          Agent.update(agent, fn {cur, max} -> {cur + 1, max(cur + 1, max)} end)
          Process.sleep(20)
          Agent.update(agent, fn {cur, max} -> {cur - 1, max} end)
        end)
      end,
      max_concurrency: 10,
      timeout: 10_000
    )
    |> Stream.run()

    {_, observed_max} = Agent.get(agent, & &1)
    assert observed_max <= 2
    assert observed_max > 0
  end

  test "releases slot when holder crashes" do
    {:ok, limiter} = Limiter.start_link(count: 1)

    # occupy-and-crash without releasing normally
    {pid, ref} =
      spawn_monitor(fn ->
        Limiter.with_slot(limiter, fn -> exit(:boom) end)
      end)

    assert_receive {:DOWN, ^ref, :process, ^pid, :boom}

    # slot must be usable again
    task = Task.async(fn -> Limiter.with_slot(limiter, fn -> :got_it end) end)
    assert Task.await(task, 1_000) == :got_it
  end

  test "queued waiters run FIFO" do
    {:ok, limiter} = Limiter.start_link(count: 1)
    parent = self()

    Limiter.with_slot(limiter, fn ->
      for i <- 1..3 do
        spawn(fn ->
          Limiter.with_slot(limiter, fn -> send(parent, {:ran, i}) end)
        end)

        # deterministic queue order
        Process.sleep(10)
      end
    end)

    assert_receive {:ran, 1}
    assert_receive {:ran, 2}
    assert_receive {:ran, 3}
  end
end
