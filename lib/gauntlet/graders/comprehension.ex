defmodule Gauntlet.Graders.Comprehension do
  @moduledoc """
  Objective grading for comprehension tasks — no sandbox involved.

    * `:predict_output` — the model's ```output block must match
      `expected.txt` after whitespace normalization (trim, strip trailing
      whitespace per line).
    * `:mcq` — the final `ANSWER: X` letter must equal the task's answer.
  """

  @behaviour Gauntlet.Graders.Grader

  alias Gauntlet.{Extract, Task}

  @impl true
  def grade(%Task{type: :predict_output} = task, %{content: content}) do
    case Extract.output_block(content) do
      nil ->
        %{status: :extraction_failed, tests: nil, subscores: %{}}

      answer ->
        expected = normalize(task.expected || "")
        actual = normalize(answer)

        %{
          status: if(actual == expected, do: :pass, else: :fail),
          tests: nil,
          subscores: %{comprehension: %{answer: answer}}
        }
    end
  end

  def grade(%Task{type: :mcq} = task, %{content: content}) do
    case Extract.mcq_answer(content) do
      nil ->
        %{status: :extraction_failed, tests: nil, subscores: %{}}

      letter ->
        %{
          status: if(letter == String.upcase(task.answer), do: :pass, else: :fail),
          tests: nil,
          subscores: %{comprehension: %{answer: letter}}
        }
    end
  end

  defp normalize(text) do
    text
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.join("\n")
  end
end
