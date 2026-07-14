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
