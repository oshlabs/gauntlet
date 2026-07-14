defmodule Gauntlet.Model do
  @moduledoc """
  Endpoint configuration for one benchmarked model, loaded from the
  `models.exs` registry at the repo root (trusted repo content).
  """

  @enforce_keys [:name, :model_spec]
  defstruct name: nil,
            model_spec: nil,
            base_url: nil,
            api_key_env: nil,
            api_key_default: "unused",
            max_concurrency: 4,
            max_tokens: 16_384,
            temperature: 0.0,
            reasoning_effort: nil,
            stream: false,
            stream_options: nil,
            reasoning: %{expected: false},
            request_timeout_ms: 300_000,
            adapter: Gauntlet.Model.ReqLlm

  @type t :: %__MODULE__{
          name: String.t(),
          model_spec: String.t(),
          base_url: String.t() | nil,
          api_key_env: String.t() | nil,
          api_key_default: String.t(),
          max_concurrency: pos_integer(),
          max_tokens: pos_integer(),
          temperature: float(),
          reasoning_effort: atom() | nil,
          stream: boolean(),
          stream_options: map() | nil,
          reasoning: map(),
          request_timeout_ms: pos_integer(),
          adapter: module()
        }

  @doc """
  Load a model by name from a models.exs registry file
  (default: `models.exs` in the current working directory).
  """
  @spec load(String.t(), keyword()) :: {:ok, t()} | {:error, term()}
  def load(name, opts \\ []) do
    path = Keyword.get(opts, :path, "models.exs")

    with {:ok, registry} <- read_registry(path),
         {:ok, config} <- fetch_model(registry, name) do
      {:ok, struct!(__MODULE__, Map.put(config, :name, name))}
    end
  end

  @doc "List model names in the registry."
  @spec names(keyword()) :: {:ok, [String.t()]} | {:error, term()}
  def names(opts \\ []) do
    path = Keyword.get(opts, :path, "models.exs")

    with {:ok, registry} <- read_registry(path) do
      {:ok, Map.keys(registry)}
    end
  end

  @valid_efforts [:none, :minimal, :low, :medium, :high, :xhigh]

  @doc """
  Apply runtime overrides (`:temperature`, `:reasoning_effort`) to a model.
  Overridden values flow into requests AND into the run's meta.json, so a
  run is always labeled with the parameters actually used.

  `reasoning_effort` accepts #{inspect(@valid_efforts)} (string or atom) or
  nil to send nothing (many servers then default to no thinking). req_llm's
  option schema does not pass a `max` tier — use `:xhigh` for the highest
  request-able effort.
  """
  @spec with_overrides(t(), keyword()) :: t()
  def with_overrides(%__MODULE__{} = model, opts) do
    model
    |> maybe_put(:temperature, opts[:temperature])
    |> maybe_put(:reasoning_effort, normalize_effort(opts[:reasoning_effort]))
  end

  defp maybe_put(model, _key, nil), do: model
  defp maybe_put(model, key, value), do: Map.put(model, key, value)

  defp normalize_effort(nil), do: nil

  defp normalize_effort(effort) when is_binary(effort),
    do: normalize_effort(String.to_existing_atom(effort))

  defp normalize_effort(effort) when effort in @valid_efforts, do: effort

  defp normalize_effort(other) do
    raise ArgumentError,
          "invalid reasoning effort #{inspect(other)}; valid: #{inspect(@valid_efforts)}"
  end

  @doc "Resolve the API key for a model from its configured env var."
  @spec api_key(t()) :: String.t()
  def api_key(%__MODULE__{api_key_env: nil, api_key_default: default}), do: default

  def api_key(%__MODULE__{api_key_env: env, api_key_default: default}) do
    System.get_env(env) || default
  end

  defp read_registry(path) do
    if File.exists?(path) do
      {registry, _} = Code.eval_file(path)
      {:ok, registry}
    else
      {:error, {:no_registry, Path.expand(path)}}
    end
  end

  defp fetch_model(registry, name) do
    case Map.fetch(registry, name) do
      {:ok, config} -> {:ok, config}
      :error -> {:error, {:unknown_model, name, Map.keys(registry)}}
    end
  end
end
