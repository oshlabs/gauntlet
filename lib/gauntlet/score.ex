defmodule Gauntlet.Score do
  @moduledoc """
  Aggregates verdicts into scores.

  Scores are always reported per dimension and split into the `curated` vs
  `smoke` tiers (smoke = contamination-prone imported tasks); the weighted
  composite comes last and is only comparable between runs with the same
  suite hash.
  """

  alias Gauntlet.{Suite, Verdict}

  @doc """
  Summarize a run's verdicts.

  Returns a map with `:dimensions` (per-dimension scores), `:tiers`
  (curated/smoke split), `:composite`, `:usage` and `:counts`.
  """
  @spec summarize([Verdict.t()], Suite.t()) :: map()
  def summarize(verdicts, %Suite{} = suite) do
    by_attempt = Enum.group_by(verdicts, &{&1.task_id, &1.sample})

    task_results =
      Enum.map(by_attempt, fn {{task_id, sample}, rounds} ->
        round1 = Enum.find(rounds, &(&1.round == 1))
        best = Enum.min_by(rounds, &if(&1.status == :pass, do: 0, else: 1))

        %{
          task_id: task_id,
          sample: sample,
          dimension: round1.dimension,
          difficulty: round1.difficulty,
          weight: round1.weight || 1.0,
          pass1: round1.status == :pass,
          pass_repair: best.status == :pass,
          repaired: round1.status != :pass and best.status == :pass,
          repair_attempted: Enum.any?(rounds, &(&1.round > 1))
        }
      end)

    dimensions =
      task_results
      |> Enum.group_by(& &1.dimension)
      |> Map.new(fn {dim, results} -> {dim, rates(results)} end)

    tiers =
      task_results
      |> Enum.group_by(&tier/1)
      |> Map.new(fn {tier, results} -> {tier, rates(results)} end)

    %{
      dimensions: dimensions,
      tiers: tiers,
      composite: composite(dimensions, suite.weights),
      usage: usage(verdicts),
      counts: counts(verdicts)
    }
  end

  defp tier(%{dimension: :knowledge}), do: :knowledge
  defp tier(%{difficulty: :smoke}), do: :smoke
  defp tier(_), do: :curated

  defp rates(results) do
    total_weight = results |> Enum.map(& &1.weight) |> Enum.sum()

    weighted = fn key ->
      case total_weight do
        w when w > 0 ->
          results
          |> Enum.filter(&Map.get(&1, key))
          |> Enum.map(& &1.weight)
          |> Enum.sum()
          |> Kernel./(w)

        _ ->
          0.0
      end
    end

    repair_base = Enum.count(results, & &1.repair_attempted)
    repaired = Enum.count(results, & &1.repaired)

    %{
      attempts: length(results),
      pass1: weighted.(:pass1),
      pass_repair: weighted.(:pass_repair),
      repair_rate: if(repair_base > 0, do: repaired / repair_base)
    }
  end

  defp composite(dimensions, weights) when map_size(dimensions) > 0 do
    present = Map.take(weights, Map.keys(dimensions))
    total = present |> Map.values() |> Enum.sum()

    case total do
      t when t > 0 ->
        present
        |> Enum.map(fn {dim, w} -> dimensions[dim].pass1 * w end)
        |> Enum.sum()
        |> Kernel./(total)

      _ ->
        nil
    end
  end

  defp composite(_, _), do: nil

  defp usage(verdicts) do
    verdicts
    |> Enum.map(& &1.usage)
    |> Enum.reduce(%{input_tokens: 0, output_tokens: 0, reasoning_tokens: 0}, fn usage, acc ->
      %{
        input_tokens: acc.input_tokens + (usage[:input_tokens] || 0),
        output_tokens: acc.output_tokens + (usage[:output_tokens] || 0),
        reasoning_tokens: acc.reasoning_tokens + (usage[:reasoning_tokens] || 0)
      }
    end)
    |> Map.put(
      :mean_latency_ms,
      case Enum.reject(Enum.map(verdicts, & &1.latency_ms), &is_nil/1) do
        [] -> nil
        latencies -> div(Enum.sum(latencies), length(latencies))
      end
    )
  end

  defp counts(verdicts) do
    verdicts
    |> Enum.group_by(& &1.status)
    |> Map.new(fn {status, vs} -> {status, length(vs)} end)
  end
end
