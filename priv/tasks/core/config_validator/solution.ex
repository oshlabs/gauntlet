defmodule ConfigValidator do
  defmodule Config do
    defstruct [:host, :port, :tls, :tags]
  end

  @known_keys ~w(host port tls tags)

  def validate(map) when is_map(map) do
    with :ok <- check_unknown(map),
         {:ok, host} <- host(map),
         {:ok, port} <- port(Map.get(map, "port", 4000)),
         {:ok, tls} <- tls(Map.get(map, "tls", false)),
         {:ok, tags} <- tags(Map.get(map, "tags", [])) do
      {:ok, %Config{host: host, port: port, tls: tls, tags: tags}}
    end
  end

  defp check_unknown(map) do
    case map |> Map.keys() |> Enum.reject(&(&1 in @known_keys)) |> Enum.sort() do
      [] -> :ok
      keys -> {:error, {:unknown_keys, keys}}
    end
  end

  defp host(map) do
    case Map.fetch(map, "host") do
      :error -> {:error, {:missing, :host}}
      {:ok, host} when is_binary(host) and host != "" -> {:ok, host}
      _ -> {:error, {:invalid, :host}}
    end
  end

  defp port(port) when is_integer(port) and port in 1..65_535, do: {:ok, port}

  defp port(port) when is_binary(port) do
    case Integer.parse(port) do
      {n, ""} when n in 1..65_535 -> {:ok, n}
      _ -> {:error, {:invalid, :port}}
    end
  end

  defp port(_), do: {:error, {:invalid, :port}}

  defp tls(tls) when is_boolean(tls), do: {:ok, tls}
  defp tls("true"), do: {:ok, true}
  defp tls("false"), do: {:ok, false}
  defp tls(_), do: {:error, {:invalid, :tls}}

  defp tags(tags) when is_list(tags) do
    if Enum.all?(tags, &(is_binary(&1) and &1 != "")) do
      {:ok, tags |> Enum.uniq() |> Enum.map(&String.to_atom/1) |> Enum.sort()}
    else
      {:error, {:invalid, :tags}}
    end
  end

  defp tags(_), do: {:error, {:invalid, :tags}}
end
