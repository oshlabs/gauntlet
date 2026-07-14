defmodule Mix.Tasks.Gauntlet.List do
  @shortdoc "List suites, tasks and models"

  @moduledoc """
  List what the benchmark knows about.

      mix gauntlet.list            # suites and their tasks
      mix gauntlet.list --models   # model registry entries
  """

  use Mix.Task

  alias Gauntlet.{Model, Suite}

  @impl true
  def run(argv) do
    Mix.Task.run("app.start")
    {opts, _, _} = OptionParser.parse(argv, strict: [models: :boolean])

    if opts[:models] do
      case Model.names() do
        {:ok, names} ->
          Enum.each(names, fn name -> Mix.shell().info(name) end)

        {:error, {:no_registry, path}} ->
          Mix.raise("No model registry at #{path}")
      end
    else
      for name <- Suite.names() do
        {:ok, suite} = Suite.load(name)
        Mix.shell().info("#{name} (#{length(suite.tasks)} tasks, #{suite.hash})")

        for task <- suite.tasks do
          Mix.shell().info(
            "  #{task.id}  [#{task.dimension}/#{task.type}/#{task.difficulty}] w=#{task.weight}"
          )
        end
      end
    end
  end
end
