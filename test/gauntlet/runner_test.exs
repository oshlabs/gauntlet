defmodule Gauntlet.RunnerTest do
  use ExUnit.Case, async: false

  alias Gauntlet.{Model, Runner, Store, Suite}

  @moduletag timeout: 180_000

  @good_adder """
  Sure, here is the solution:

  ```elixir
  defmodule Adder do
    def add(a, b), do: a + b
  end
  ```
  """

  @bad_adder """
  ```elixir
  defmodule Adder do
    def add(a, b), do: a - b
  end
  ```
  """

  setup do
    Gauntlet.Model.Fake.reset()

    runs_dir =
      Path.join(System.tmp_dir!(), "gauntlet_runner_test_#{System.unique_integer([:positive])}")

    on_exit(fn -> File.rm_rf!(runs_dir) end)

    model = %Model{
      name: "fake",
      model_spec: "openai:fake",
      max_concurrency: 2,
      adapter: Gauntlet.Model.Fake
    }

    {:ok, suite} = Suite.load("mini", tasks_dir: "test/fixtures/tasks")
    %{model: model, suite: suite, runs_dir: runs_dir}
  end

  defp respond_by_task(responses) do
    Gauntlet.Model.Fake.set_handler(fn _model, messages, _opts ->
      user = messages |> Enum.filter(&(&1.role == :user)) |> List.first()

      {_key, response} =
        Enum.find(responses, fn {key, _} -> user.content =~ key end) ||
          {nil, ""}

      {:ok,
       %{
         content: response,
         thinking: nil,
         usage: %{input_tokens: 10, output_tokens: 20},
         finish_reason: :stop,
         latency_ms: 5
       }}
    end)
  end

  test "full run: pass, fail and comprehension verdicts + artifacts", ctx do
    respond_by_task(%{
      "Adder" => @good_adder,
      "pin operator" => "ANSWER: B",
      "upcased" => "String.upcase(input)"
    })

    {:ok, %{summary: summary, run_dir: run_dir, verdicts: verdicts}} =
      Runner.run(ctx.model, ctx.suite, runs_dir: ctx.runs_dir, progress: fn _ -> :ok end)

    assert length(verdicts) == 3
    assert Enum.all?(verdicts, &(&1.status == :pass))

    # scores
    assert summary.dimensions.generation.pass1 == 1.0
    assert summary.dimensions.comprehension.pass1 == 1.0
    assert summary.dimensions.knowledge.pass1 == 1.0
    assert summary.tiers.knowledge.pass1 == 1.0
    assert summary.composite == 1.0
    assert summary.usage.output_tokens == 60

    # artifacts
    assert File.regular?(Path.join(run_dir, "meta.json"))
    assert File.regular?(Path.join(run_dir, "report.md"))
    assert File.regular?(Path.join(run_dir, "summary.json"))
    assert length(Store.read_verdicts(run_dir)) == 3

    meta = Store.read_meta(run_dir)
    assert meta["suite"]["hash"] =~ "sha256:"
    assert meta["model"]["id"] == "fake"

    # passing attempts pruned
    assert File.ls!(Path.join(run_dir, "attempts")) == []
  end

  test "failing code task gets a repair round that can succeed", ctx do
    # round 1 wrong, round 2 (repair) correct
    Gauntlet.Model.Fake.set_handler(fn _model, messages, _opts ->
      response =
        cond do
          Enum.any?(messages, &(&1.role == :assistant)) -> @good_adder
          List.last(messages).content =~ "pin operator" -> "ANSWER: B"
          true -> @bad_adder
        end

      {:ok, %{content: response, thinking: nil, usage: %{}, finish_reason: :stop, latency_ms: 1}}
    end)

    {:ok, %{summary: summary, verdicts: verdicts}} =
      Runner.run(ctx.model, ctx.suite,
        runs_dir: ctx.runs_dir,
        repair: true,
        progress: fn _ -> :ok end
      )

    adder_verdicts = Enum.filter(verdicts, &(&1.task_id == "mini/adder"))

    assert [%{round: 1, status: :fail}, %{round: 2, status: :pass}] =
             Enum.sort_by(adder_verdicts, & &1.round)

    assert summary.dimensions.generation.pass1 == 0.0
    assert summary.dimensions.generation.pass_repair == 1.0
    assert summary.dimensions.generation.repair_rate == 1.0
  end

  test "no code block is an extraction failure", ctx do
    respond_by_task(%{"Adder" => "I cannot help with that.", "pin operator" => "ANSWER: A"})

    {:ok, %{verdicts: verdicts, summary: summary}} =
      Runner.run(ctx.model, ctx.suite, runs_dir: ctx.runs_dir, progress: fn _ -> :ok end)

    adder = Enum.find(verdicts, &(&1.task_id == "mini/adder"))
    mcq = Enum.find(verdicts, &(&1.task_id == "mini/mcq_pin"))

    assert adder.status == :extraction_failed
    assert mcq.status == :fail
    assert summary.composite == 0.0
  end

  test "llm errors survive as llm_error verdicts", ctx do
    Gauntlet.Model.Fake.set_handler(fn _model, _messages, _opts ->
      {:error, :connection_refused}
    end)

    {:ok, %{verdicts: verdicts}} =
      Runner.run(ctx.model, ctx.suite, runs_dir: ctx.runs_dir, progress: fn _ -> :ok end)

    assert Enum.all?(verdicts, &(&1.status == :llm_error))
  end

  test "truncated responses are marked truncated", ctx do
    Gauntlet.Model.Fake.set_handler(fn _model, _messages, _opts ->
      {:ok,
       %{content: "partial", thinking: nil, usage: %{}, finish_reason: :length, latency_ms: 1}}
    end)

    {:ok, %{verdicts: verdicts}} =
      Runner.run(ctx.model, ctx.suite, runs_dir: ctx.runs_dir, progress: fn _ -> :ok end)

    assert Enum.all?(verdicts, &(&1.status == :truncated))
  end
end
