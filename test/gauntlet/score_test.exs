defmodule Gauntlet.ScoreTest do
  use ExUnit.Case, async: true

  alias Gauntlet.{Score, Suite, Verdict}

  defp suite(weights) do
    %Suite{name: "s", tasks: [], weights: weights, hash: "sha256:x"}
  end

  defp verdict(task_id, status, attrs \\ []) do
    struct!(
      %Verdict{
        task_id: task_id,
        model: "m",
        sample: 1,
        round: 1,
        status: status,
        dimension: :generation,
        difficulty: :medium,
        weight: 1.0
      },
      attrs
    )
  end

  test "pass@1 weighted by task weight" do
    verdicts = [
      verdict("a", :pass, weight: 2.0),
      verdict("b", :fail, weight: 1.0),
      verdict("c", :fail, weight: 1.0)
    ]

    summary = Score.summarize(verdicts, suite(%{generation: 1.0}))
    assert summary.dimensions.generation.pass1 == 0.5
    assert summary.composite == 0.5
  end

  test "repair rate counts round-2 rescues over attempted repairs" do
    verdicts = [
      verdict("a", :fail),
      verdict("a", :pass, round: 2),
      verdict("b", :fail),
      verdict("b", :fail, round: 2),
      verdict("c", :pass)
    ]

    summary = Score.summarize(verdicts, suite(%{generation: 1.0}))
    gen = summary.dimensions.generation
    assert gen.pass1 == 1 / 3
    assert gen.pass_repair == 2 / 3
    assert gen.repair_rate == 0.5
  end

  test "smoke and curated tiers split" do
    verdicts = [
      verdict("smoke1", :pass, difficulty: :smoke),
      verdict("smoke2", :pass, difficulty: :smoke),
      verdict("hard1", :fail, difficulty: :hard)
    ]

    summary = Score.summarize(verdicts, suite(%{generation: 1.0}))
    assert summary.tiers.smoke.pass1 == 1.0
    assert summary.tiers.curated.pass1 == 0.0
  end

  test "composite ignores absent dimensions and renormalizes" do
    verdicts = [verdict("a", :pass)]

    summary =
      Score.summarize(verdicts, suite(%{generation: 0.5, comprehension: 0.5}))

    assert summary.composite == 1.0
  end

  test "usage totals" do
    verdicts = [
      verdict("a", :pass, usage: %{input_tokens: 10, output_tokens: 5, reasoning_tokens: 100}),
      verdict("b", :fail, usage: %{input_tokens: 1, output_tokens: 2})
    ]

    summary = Score.summarize(verdicts, suite(%{generation: 1.0}))
    assert summary.usage.input_tokens == 11
    assert summary.usage.output_tokens == 7
    assert summary.usage.reasoning_tokens == 100
  end
end
