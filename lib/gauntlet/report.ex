defmodule Gauntlet.Report do
  @moduledoc """
  Renders run summaries as markdown. Per-dimension and per-tier tables come
  first; the composite is printed last with its suite hash, since it is only
  comparable between identical suites.
  """

  @doc "Render one run's summary."
  @spec render(map(), map()) :: String.t()
  def render(summary, meta) do
    """
    # Gauntlet run — #{get_in_any(meta, [:model, :id]) || "?"}

    - Suite: `#{get_in_any(meta, [:suite, :name])}` (#{get_in_any(meta, [:suite, :task_count])} tasks)
    - Suite hash: `#{get_in_any(meta, [:suite, :hash])}`
    - Run: `#{get_in_any(meta, [:run_id])}`

    ## Dimensions

    #{table(summary.dimensions)}

    ## Tiers

    #{table(summary.tiers)}

    ## Outcome counts

    #{counts_table(summary.counts)}

    ## Usage

    - Input tokens: #{summary.usage.input_tokens}
    - Output tokens: #{summary.usage.output_tokens}
    - Reasoning tokens: #{summary.usage.reasoning_tokens}
    - Mean latency: #{format_ms(summary.usage.mean_latency_ms)}

    ## Composite

    **#{summary.composite || "n/a"}** (weighted pass@1; only comparable at identical suite hash)
    """
  end

  defp table(groups) when map_size(groups) == 0, do: "_none_"

  defp table(groups) do
    header = "| group | attempts | pass@1 | pass@repair | repair rate |\n|---|---|---|---|---|"

    rows =
      groups
      |> Enum.sort_by(fn {k, _} -> to_string(k) end)
      |> Enum.map(fn {name, r} ->
        "| #{name} | #{r.attempts} | #{percent(r.pass1)} | #{percent(r.pass_repair)} | #{percent(r.repair_rate)} |"
      end)

    Enum.join([header | rows], "\n")
  end

  defp counts_table(counts) when map_size(counts) == 0, do: "_none_"

  defp counts_table(counts) do
    counts
    |> Enum.sort_by(fn {_, n} -> -n end)
    |> Enum.map_join("\n", fn {status, n} -> "- #{status}: #{n}" end)
  end

  defp percent(nil), do: "—"
  defp percent(x), do: "#{Float.round(x * 100, 1)}%"

  defp format_ms(nil), do: "—"
  defp format_ms(ms) when ms >= 1000, do: "#{Float.round(ms / 1000, 1)}s"
  defp format_ms(ms), do: "#{ms}ms"

  # meta may come from a live run (atom keys) or meta.json (string keys)
  defp get_in_any(map, keys) do
    Enum.reduce_while(keys, map, fn key, acc ->
      case acc do
        %{} -> {:cont, Map.get(acc, key) || Map.get(acc, to_string(key))}
        _ -> {:halt, nil}
      end
    end)
  end
end
