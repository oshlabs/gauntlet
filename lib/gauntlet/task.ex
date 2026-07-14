defmodule Gauntlet.Task do
  @moduledoc """
  A single benchmark task: metadata from `task.exs` plus the on-disk files
  (prompt, stub, hidden checks, reference solution) that define it.

  Task directories live under `priv/tasks/<pack>/<task_id>/`:

      task.exs      -- metadata map (trusted repo content)
      prompt.md     -- instructions shown to the model
      stub.ex       -- optional starting code included in the prompt
      context.md    -- optional docs for the context-injection toggle
      solution.ex   -- reference solution (mix gauntlet.validate), never shown
      buggy.ex      -- debugging tasks: the code to fix
      checks/       -- hidden ExUnit test files copied into the sandbox
      expected.txt  -- comprehension tasks: expected output
  """

  @enforce_keys [:id, :dimension, :type, :difficulty, :dir]
  defstruct id: nil,
            dimension: nil,
            type: nil,
            difficulty: nil,
            tags: [],
            module_name: nil,
            graders: [:ex_unit],
            behavioral: nil,
            timeout_ms: 60_000,
            max_tokens: nil,
            weight: 1.0,
            answer: nil,
            dir: nil,
            prompt: nil,
            stub: nil,
            context: nil,
            solution: nil,
            buggy: nil,
            expected: nil,
            failure_output: nil,
            check_files: []

  @type dimension :: :generation | :comprehension | :debugging | :quality
  @type task_type :: :write_code | :fix_code | :predict_output | :mcq

  @type t :: %__MODULE__{
          id: String.t(),
          dimension: dimension(),
          type: task_type(),
          difficulty: :smoke | :easy | :medium | :hard,
          tags: [atom()],
          module_name: String.t() | nil,
          graders: [atom()],
          behavioral: map() | nil,
          timeout_ms: pos_integer(),
          max_tokens: pos_integer() | nil,
          weight: float(),
          answer: String.t() | nil,
          dir: String.t(),
          prompt: String.t() | nil,
          stub: String.t() | nil,
          context: String.t() | nil,
          solution: String.t() | nil,
          buggy: String.t() | nil,
          expected: String.t() | nil,
          failure_output: String.t() | nil,
          check_files: [{String.t(), String.t()}]
        }

  @dimensions [:generation, :comprehension, :debugging, :quality]
  @types [:write_code, :fix_code, :predict_output, :mcq]
  @difficulties [:smoke, :easy, :medium, :hard]

  @doc """
  Load a task from its directory. Raises on invalid metadata.
  """
  @spec load!(String.t()) :: t()
  def load!(dir) do
    meta_path = Path.join(dir, "task.exs")

    unless File.exists?(meta_path) do
      raise ArgumentError, "no task.exs in #{dir}"
    end

    {meta, _} = Code.eval_file(meta_path)
    validate!(meta, dir)

    %__MODULE__{
      id: meta.id,
      dimension: meta.dimension,
      type: meta.type,
      difficulty: meta.difficulty,
      tags: Map.get(meta, :tags, []),
      module_name: Map.get(meta, :module_name),
      graders: Map.get(meta, :graders, default_graders(meta.type)),
      behavioral: Map.get(meta, :behavioral),
      timeout_ms: Map.get(meta, :timeout_ms, 60_000),
      max_tokens: Map.get(meta, :max_tokens),
      weight: Map.get(meta, :weight, 1.0) * 1.0,
      answer: Map.get(meta, :answer),
      dir: dir,
      prompt: read_optional(dir, "prompt.md"),
      stub: read_optional(dir, "stub.ex"),
      context: read_optional(dir, "context.md"),
      solution: read_optional(dir, "solution.ex"),
      buggy: read_optional(dir, "buggy.ex"),
      expected: read_optional(dir, "expected.txt"),
      failure_output: read_optional(dir, "checks/failure_output.txt"),
      check_files: read_checks(dir)
    }
  end

  @doc "Whether this task's grading requires the sandbox (compile + ExUnit)."
  @spec needs_sandbox?(t()) :: boolean()
  def needs_sandbox?(%__MODULE__{type: type}), do: type in [:write_code, :fix_code]

  defp default_graders(:write_code), do: [:ex_unit]
  defp default_graders(:fix_code), do: [:ex_unit]
  defp default_graders(:predict_output), do: [:comprehension]
  defp default_graders(:mcq), do: [:comprehension]

  defp read_optional(dir, rel) do
    path = Path.join(dir, rel)
    if File.regular?(path), do: File.read!(path)
  end

  # checks/*.exs except recorded failure output; returned as {filename, contents}
  defp read_checks(dir) do
    checks = Path.join(dir, "checks")

    if File.dir?(checks) do
      checks
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".exs"))
      |> Enum.sort()
      |> Enum.map(&{&1, File.read!(Path.join(checks, &1))})
    else
      []
    end
  end

  defp validate!(meta, dir) do
    unless is_map(meta), do: raise(ArgumentError, "task.exs in #{dir} must evaluate to a map")

    for key <- [:id, :dimension, :type, :difficulty] do
      unless Map.has_key?(meta, key) do
        raise ArgumentError, "task.exs in #{dir} missing #{inspect(key)}"
      end
    end

    unless meta.dimension in @dimensions,
      do: raise(ArgumentError, "#{dir}: bad dimension #{inspect(meta.dimension)}")

    unless meta.type in @types,
      do: raise(ArgumentError, "#{dir}: bad type #{inspect(meta.type)}")

    unless meta.difficulty in @difficulties,
      do: raise(ArgumentError, "#{dir}: bad difficulty #{inspect(meta.difficulty)}")

    if meta.type in [:write_code, :fix_code] and not Map.has_key?(meta, :module_name),
      do: raise(ArgumentError, "#{dir}: #{meta.type} task needs :module_name")

    if meta.type == :mcq and not Map.has_key?(meta, :answer),
      do: raise(ArgumentError, "#{dir}: mcq task needs :answer")

    :ok
  end
end
