defmodule Mix.Tasks.Gauntlet.Run do
  @shortdoc "Run a benchmark suite against a model"

  @moduledoc """
  Run a benchmark suite against a model from the models.exs registry.

      mix gauntlet.run --model deepseek-v4-flash [--suite default]
        [--samples 1] [--repair] [--context] [--only SUBSTR] [--runs-dir runs]
        [--temperature 0.0] [--reasoning none|minimal|low|medium|high|xhigh]

  `--temperature` and `--reasoning` override the model registry entry for
  this run only; the values actually used are recorded in the run's
  meta.json. Without `--reasoning` (and no registry default), no reasoning
  effort is requested — reasoning-capable servers then typically answer
  without thinking.

  Prints the report and the run directory when done.
  """

  use Mix.Task

  @switches [
    model: :string,
    suite: :string,
    samples: :integer,
    repair: :boolean,
    context: :boolean,
    only: :string,
    runs_dir: :string,
    models_path: :string,
    temperature: :float,
    reasoning: :string
  ]

  @impl true
  def run(argv) do
    Mix.Task.run("app.start")
    {opts, _, _} = OptionParser.parse(argv, strict: @switches)

    model = opts[:model] || Mix.raise("--model is required (see mix gauntlet.list)")
    suite = opts[:suite] || "default"

    run_opts =
      [
        samples: opts[:samples] || 1,
        repair: opts[:repair] || false,
        context_injection: opts[:context] || false,
        progress: fn msg -> Mix.shell().info(msg) end
      ]
      |> put_if(:only, opts[:only])
      |> put_if(:runs_dir, opts[:runs_dir])
      |> put_if(:models_path, opts[:models_path])
      |> put_if(:temperature, opts[:temperature])
      |> put_if(:reasoning_effort, opts[:reasoning])

    case Gauntlet.run(model, suite, run_opts) do
      {:ok, %{run_dir: run_dir}} ->
        Mix.shell().info("\n" <> File.read!(Path.join(run_dir, "report.md")))
        Mix.shell().info("Run stored in #{run_dir}")

      {:error, reason} ->
        Mix.raise("Run failed: #{inspect(reason)}")
    end
  end

  defp put_if(opts, _key, nil), do: opts
  defp put_if(opts, key, value), do: Keyword.put(opts, key, value)
end
