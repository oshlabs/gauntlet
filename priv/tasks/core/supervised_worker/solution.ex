defmodule Watchdog.Worker do
  use GenServer

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def child_spec(opts) do
    %{
      id: Keyword.fetch!(opts, :name),
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def increment(name), do: GenServer.call(name, :increment)
  def value(name), do: GenServer.call(name, :value)
  def crash(name), do: GenServer.cast(name, :crash)

  @impl true
  def init(:ok), do: {:ok, 0}

  @impl true
  def handle_call(:increment, _from, count), do: {:reply, count + 1, count + 1}
  def handle_call(:value, _from, count), do: {:reply, count, count}

  @impl true
  def handle_cast(:crash, count), do: {:stop, :crashed, count}
end

defmodule Watchdog do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Watchdog.Worker, name: :wd_alpha},
      {Watchdog.Worker, name: :wd_beta}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 10, max_seconds: 5)
  end
end
