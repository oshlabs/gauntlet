defmodule Gauntlet.Limiter do
  @moduledoc """
  Counting semaphore used to cap concurrent LLM requests and concurrent
  sandbox runs independently. Internal to the runner — callers use
  `with_slot/2` and never talk to the GenServer directly.
  """

  use GenServer

  @doc "Start a limiter with `count` slots."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    count = Keyword.fetch!(opts, :count)
    GenServer.start_link(__MODULE__, count, name: Keyword.get(opts, :name))
  end

  @doc "Run `fun` while holding one slot; blocks until a slot is free."
  @spec with_slot(GenServer.server(), (-> result)) :: result when result: var
  def with_slot(limiter, fun) do
    :ok = GenServer.call(limiter, :acquire, :infinity)

    try do
      fun.()
    after
      GenServer.cast(limiter, {:release, self()})
    end
  end

  @impl true
  def init(count) do
    {:ok, %{free: count, waiting: :queue.new(), holders: %{}}}
  end

  @impl true
  def handle_call(:acquire, {pid, _} = from, state) do
    if state.free > 0 do
      {:reply, :ok, grant(state, pid, %{state | free: state.free - 1})}
    else
      {:noreply, %{state | waiting: :queue.in(from, state.waiting)}}
    end
  end

  @impl true
  def handle_cast({:release, pid}, state) do
    {:noreply, release(pid, state)}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # Holder died without releasing — reclaim its slot.
    if Map.has_key?(state.holders, pid) do
      {:noreply, release(pid, state)}
    else
      {:noreply, state}
    end
  end

  defp grant(_old, pid, state) do
    ref = Process.monitor(pid)
    %{state | holders: Map.put(state.holders, pid, ref)}
  end

  defp release(pid, state) do
    state =
      case Map.pop(state.holders, pid) do
        {nil, _} ->
          state

        {ref, holders} ->
          Process.demonitor(ref, [:flush])
          %{state | holders: holders}
      end

    case :queue.out(state.waiting) do
      {{:value, {waiter_pid, _} = from}, rest} ->
        GenServer.reply(from, :ok)
        grant(state, waiter_pid, %{state | waiting: rest})

      {:empty, _} ->
        %{state | free: state.free + 1}
    end
  end
end
