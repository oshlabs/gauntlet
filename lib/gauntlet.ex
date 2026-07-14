defmodule Gauntlet do
  @moduledoc """
  Gauntlet — a repeatable benchmark of LLM capability at Elixir.

  Models are graded across four dimensions (generation, comprehension,
  debugging, quality) on tasks that compile and run for real: code answers
  are executed against hidden ExUnit suites in throwaway sandbox projects,
  never inside the harness BEAM.

      Gauntlet.run("deepseek-v4-flash", "default", repair: true)
  """

  alias Gauntlet.{Model, Runner, Suite}

  @doc """
  Run a named suite against a named model from the `models.exs` registry.

  Options are passed through to `Gauntlet.Runner.run/3` (`:samples`,
  `:repair`, `:context_injection`, `:runs_dir`) and `Gauntlet.Suite.load/2`
  (`:only`, `:tags`, `:tasks_dir`); `:models_path` overrides the registry
  location.
  """
  @spec run(String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def run(model_name, suite_name \\ "default", opts \\ []) do
    with {:ok, model} <-
           Model.load(model_name, path: Keyword.get(opts, :models_path, "models.exs")),
         {:ok, suite} <- Suite.load(suite_name, opts) do
      if suite.tasks == [] do
        {:error, :no_tasks_selected}
      else
        Runner.run(model, suite, opts)
      end
    end
  end
end
