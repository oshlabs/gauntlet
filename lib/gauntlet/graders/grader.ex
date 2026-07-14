defmodule Gauntlet.Graders.Grader do
  @moduledoc """
  Behaviour for verdict graders.

  A grader receives the task and the attempt context (model output, extracted
  code, sandbox result when one ran) and returns a status plus named
  subscores that are merged into the verdict.
  """

  @type ctx :: %{
          optional(:content) => String.t(),
          optional(:code) => String.t(),
          optional(:sandbox) => Gauntlet.Sandbox.test_result()
        }

  @callback grade(Gauntlet.Task.t(), ctx()) ::
              %{status: Gauntlet.Verdict.status(), subscores: map(), tests: map() | nil}
end
