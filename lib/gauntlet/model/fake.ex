defmodule Gauntlet.Model.Fake do
  @moduledoc """
  Canned completion backend for LLM-free harness tests.

  State lives in a globally named Agent (the runner executes attempts in
  spawned tasks, so process-local state would not be visible). Tests using
  this adapter through the runner should be `async: false`.

  Configure with `set_responses/1` (a queue consumed in order) or
  `set_handler/1` (a fun receiving `(model, messages, opts)`).
  """

  @behaviour Gauntlet.Model.Adapter

  use Agent

  @doc false
  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{responses: [], handler: nil} end, name: __MODULE__)
  end

  @doc "Queue canned responses (strings or full result maps), clearing any handler."
  @spec set_responses([String.t() | map()]) :: :ok
  def set_responses(responses) do
    ensure_started()
    Agent.update(__MODULE__, fn _ -> %{responses: responses, handler: nil} end)
  end

  @doc "Set a fun `(model, messages, opts) -> {:ok, result} | {:error, term}`."
  @spec set_handler((Gauntlet.Model.t(), [map()], keyword() -> {:ok, map()} | {:error, term()})) ::
          :ok
  def set_handler(fun) when is_function(fun, 3) do
    ensure_started()
    Agent.update(__MODULE__, fn _ -> %{responses: [], handler: fun} end)
  end

  @doc "Reset to empty state."
  @spec reset() :: :ok
  def reset do
    ensure_started()
    Agent.update(__MODULE__, fn _ -> %{responses: [], handler: nil} end)
  end

  @impl true
  def complete(model, messages, opts \\ []) do
    ensure_started()

    next =
      Agent.get_and_update(__MODULE__, fn
        %{handler: handler} = state when is_function(handler) ->
          {{:handler, handler}, state}

        %{responses: [next | rest]} = state ->
          {{:response, next}, %{state | responses: rest}}

        %{responses: []} = state ->
          {{:response, ""}, state}
      end)

    case next do
      {:handler, handler} -> handler.(model, messages, opts)
      {:response, response} -> {:ok, normalize(response)}
    end
  end

  defp ensure_started do
    case Process.whereis(__MODULE__) do
      nil ->
        case start_link() do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
        end

      _pid ->
        :ok
    end
  end

  defp normalize(content) when is_binary(content) do
    %{content: content, thinking: nil, usage: %{}, finish_reason: :stop, latency_ms: 0}
  end

  defp normalize(%{} = result) do
    Map.merge(
      %{content: "", thinking: nil, usage: %{}, finish_reason: :stop, latency_ms: 0},
      result
    )
  end
end
