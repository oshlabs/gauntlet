defmodule TtlStore do
  use GenServer

  # state: %{key => {value, timer_ref, tag}} — the tag identifies which
  # scheduled expiry is current, so stale timer messages are ignored.

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def put(server, key, value, ttl_ms), do: GenServer.call(server, {:put, key, value, ttl_ms})
  def get(server, key), do: GenServer.call(server, {:get, key})
  def delete(server, key), do: GenServer.call(server, {:delete, key})
  def size(server), do: GenServer.call(server, :size)

  @impl true
  def init(:ok), do: {:ok, %{}}

  @impl true
  def handle_call({:put, key, value, ttl_ms}, _from, state) do
    state = cancel_entry(state, key)
    tag = make_ref()
    ref = Process.send_after(self(), {:expire, key, tag}, ttl_ms)
    {:reply, :ok, Map.put(state, key, {value, ref, tag})}
  end

  def handle_call({:get, key}, _from, state) do
    case state do
      %{^key => {value, _ref, _tag}} -> {:reply, {:ok, value}, state}
      _ -> {:reply, :error, state}
    end
  end

  def handle_call({:delete, key}, _from, state) do
    {:reply, :ok, cancel_entry(state, key)}
  end

  def handle_call(:size, _from, state) do
    {:reply, map_size(state), state}
  end

  @impl true
  def handle_info({:expire, key, tag}, state) do
    case state do
      %{^key => {_value, _ref, ^tag}} -> {:noreply, Map.delete(state, key)}
      _ -> {:noreply, state}
    end
  end

  defp cancel_entry(state, key) do
    case state do
      %{^key => {_value, ref, _tag}} ->
        Process.cancel_timer(ref)
        Map.delete(state, key)

      _ ->
        state
    end
  end
end
