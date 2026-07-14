defmodule Gauntlet.Graders.ExUnit do
  @moduledoc """
  Grades a code task from its sandbox `mix test` result: pass iff every
  hidden test passed.
  """

  @behaviour Gauntlet.Graders.Grader

  @impl true
  def grade(_task, %{sandbox: result}) do
    %{
      status: result.status,
      tests: result.tests,
      subscores: %{ex_unit: %{exit_status: result.exit_status}}
    }
  end
end
