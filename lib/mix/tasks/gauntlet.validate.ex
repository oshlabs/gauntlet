defmodule Mix.Tasks.Gauntlet.Validate do
  @shortdoc "Run every task's reference solution through the pipeline"

  @moduledoc """
  CI for the task packs: every task's reference solution must grade as a
  pass through the same sandbox + graders a model's answer would use. No
  LLM involved.

      mix gauntlet.validate [--suite default] [--only SUBSTR]
  """

  use Mix.Task

  alias Gauntlet.{Graders, Sandbox, Suite}
  alias Gauntlet.Task, as: BenchTask

  @switches [suite: :string, only: :string]

  @impl true
  def run(argv) do
    Mix.Task.run("app.start")
    {opts, _, _} = OptionParser.parse(argv, strict: @switches)

    suite_opts = if opts[:only], do: [only: opts[:only]], else: []

    {:ok, suite} = Suite.load(opts[:suite] || "default", suite_opts)

    if suite.tasks == [] do
      Mix.raise("No tasks selected")
    end

    work_dir = Path.join(System.tmp_dir!(), "gauntlet_validate_#{System.os_time(:millisecond)}")
    File.mkdir_p!(work_dir)
    {:ok, template} = Sandbox.Template.prepare(work_dir)

    failures =
      suite.tasks
      |> Task.async_stream(&validate(&1, template, work_dir),
        max_concurrency: max(div(System.schedulers_online(), 2), 1),
        ordered: false,
        timeout: :infinity
      )
      |> Enum.flat_map(fn {:ok, result} -> result end)

    File.rm_rf!(work_dir)

    case failures do
      [] ->
        Mix.shell().info("#{length(suite.tasks)} tasks validated, all reference solutions pass.")

      _ ->
        for {id, reason} <- failures do
          Mix.shell().error("FAIL #{id}: #{reason}")
        end

        Mix.raise("#{length(failures)} of #{length(suite.tasks)} tasks failed validation")
    end
  end

  defp validate(%BenchTask{type: type} = task, template, work_dir)
       when type in [:write_code, :fix_code] do
    cond do
      task.solution == nil ->
        [{task.id, "no solution.ex"}]

      task.check_files == [] ->
        [{task.id, "no checks/*.exs"}]

      true ->
        attempt_dir = Path.join([work_dir, "validate", sanitize(task.id)])
        Sandbox.materialize(template, task, task.solution, attempt_dir)
        result = Sandbox.run_tests(attempt_dir, timeout_ms: task.timeout_ms)
        graded = Graders.ExUnit.grade(task, %{sandbox: result})

        if graded.status == :pass do
          Mix.shell().info("ok   #{task.id} (#{result.tests.passed}/#{result.tests.total})")
          []
        else
          [{task.id, "#{graded.status}\n#{tail(result.output, 2_000)}"}]
        end
    end
  end

  defp validate(%BenchTask{type: :predict_output} = task, _template, _work_dir) do
    cond do
      task.expected == nil ->
        [{task.id, "no expected.txt"}]

      task.stub == nil ->
        [{task.id, "no stub.ex (the program to predict)"}]

      true ->
        # Verify expected.txt by actually executing the program.
        case run_program(task) do
          {output, 0} ->
            graded =
              Graders.Comprehension.grade(task, %{content: "```output\n#{output}\n```"})

            if graded.status == :pass do
              Mix.shell().info("ok   #{task.id}")
              []
            else
              [{task.id, "expected.txt does not match actual output:\n#{tail(output, 2_000)}"}]
            end

          {output, status} ->
            [{task.id, "program exited #{status}:\n#{tail(output, 2_000)}"}]
        end
    end
  end

  defp validate(%BenchTask{type: :mcq} = task, _template, _work_dir) do
    if task.answer in ~w(A B C D E) do
      Mix.shell().info("ok   #{task.id}")
      []
    else
      [{task.id, "mcq answer must be a letter, got #{inspect(task.answer)}"}]
    end
  end

  defp run_program(task) do
    dir = Path.join(System.tmp_dir!(), "gauntlet_predict_#{sanitize(task.id)}")
    File.mkdir_p!(dir)
    path = Path.join(dir, "program.exs")
    File.write!(path, task.stub)

    try do
      System.cmd("elixir", [path], stderr_to_stdout: true, cd: dir)
    after
      File.rm_rf!(dir)
    end
  end

  defp sanitize(name), do: String.replace(name, ~r/[^A-Za-z0-9._-]/, "-")

  defp tail(text, max) when byte_size(text) > max,
    do: "…" <> binary_part(text, byte_size(text) - max, max)

  defp tail(text, _max), do: text
end
