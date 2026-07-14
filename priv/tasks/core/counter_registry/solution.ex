defmodule CounterFarm.Counter do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, :ok, name: CounterFarm.via(id))
  end

  @impl true
  def init(:ok), do: {:ok, 0}

  @impl true
  def handle_call(:incr, _from, count), do: {:reply, count + 1, count + 1}
  def handle_call(:value, _from, count), do: {:reply, count, count}
end

defmodule CounterFarm do
  use Supervisor

  @registry CounterFarm.Registry
  @dynsup CounterFarm.DynamicSupervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: @registry},
      {DynamicSupervisor, strategy: :one_for_one, name: @dynsup}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  def via(id), do: {:via, Registry, {@registry, id}}

  def incr(id) do
    GenServer.call(ensure_started(id), :incr)
  end

  def value(id) do
    case which(id) do
      {:ok, pid} -> GenServer.call(pid, :value)
      :error -> 0
    end
  end

  def which(id) do
    case Registry.lookup(@registry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> :error
    end
  end

  def count do
    DynamicSupervisor.count_children(@dynsup).active
  end

  defp ensure_started(id) do
    case DynamicSupervisor.start_child(@dynsup, {CounterFarm.Counter, id}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
