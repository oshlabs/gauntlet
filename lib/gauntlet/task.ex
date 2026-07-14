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
            wrapper: nil,
            check_files: []

  @type dimension :: :generation | :comprehension | :debugging | :quality | :knowledge
  @type task_type :: :write_code | :fix_code | :predict_output | :mcq | :snippet

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

  @dimensions [:generation, :comprehension, :debugging, :quality, :knowledge]
  @types [:write_code, :fix_code, :predict_output, :mcq, :snippet]
  @difficulties [:smoke, :easy, :medium, :hard]

  # `_ = input` keeps snippets that ignore the input warning-free.
  @default_wrapper """
  defmodule Micro do
    def solve(input) do
      _ = input
      __SNIPPET__
    end
  end
  """

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

  @doc """
  Build a task from a micro-item map (an entry in a pack's `<theme>.exs`
  item file). Items are tiny knowledge probes: the model answers with a
  bare expression that gets spliced into a wrapper module, then graded by a
  test file generated from the item's `checks`.

  Item shape:

      %{
        id: "enum/double",                       # pack-relative
        prompt: "`input` is a list of numbers. Return it with every value doubled.",
        solution: "Enum.map(input, &(&1 * 2))",  # reference snippet
        checks: [{"[1, 2, 3]", "[2, 4, 6]"}, {"[]", "[]"}],
        raw_checks: ["assert_raise ArgumentError, fn -> Micro.solve(:x) end"],  # optional
        tags: [:enum],                            # optional
        difficulty: :easy,                        # optional, default :easy
        weight: 1.0,                              # optional, default 1.0
        wrapper: "defmodule Micro do ... __SNIPPET__ ... end"  # optional override
      }
  """
  @spec from_item!(String.t(), String.t(), map()) :: t()
  def from_item!(pack, source_file, item) do
    for key <- [:id, :prompt, :solution] do
      unless Map.has_key?(item, key) do
        raise ArgumentError, "item in #{source_file} missing #{inspect(key)}: #{inspect(item)}"
      end
    end

    checks = Map.get(item, :checks, [])
    raw_checks = Map.get(item, :raw_checks, [])

    if checks == [] and raw_checks == [] do
      raise ArgumentError, "item #{item.id} in #{source_file} has no checks"
    end

    wrapper = Map.get(item, :wrapper, @default_wrapper)

    unless String.contains?(wrapper, "__SNIPPET__") do
      raise ArgumentError, "item #{item.id} wrapper has no __SNIPPET__ placeholder"
    end

    %__MODULE__{
      id: "#{pack}/#{item.id}",
      dimension: :knowledge,
      type: :snippet,
      difficulty: Map.get(item, :difficulty, :easy),
      tags: Map.get(item, :tags, []),
      module_name: "Micro",
      graders: [:ex_unit],
      timeout_ms: Map.get(item, :timeout_ms, 30_000),
      max_tokens: Map.get(item, :max_tokens, 8_192),
      weight: Map.get(item, :weight, 1.0) * 1.0,
      dir: source_file,
      prompt: item.prompt,
      wrapper: wrapper,
      solution: splice_snippet(wrapper, item.solution),
      check_files: [{"solution_test.exs", item_test_file(checks, raw_checks)}]
    }
  end

  @doc """
  Insert a snippet into a wrapper module. If the snippet already defines
  the wrapper module itself (a model ignoring the answer format), it is
  used as-is — the tests still decide.
  """
  @spec splice_snippet(String.t(), String.t()) :: String.t()
  def splice_snippet(wrapper, snippet) do
    if snippet =~ ~r/\bdefmodule\s+Micro\b/ do
      snippet
    else
      String.replace(wrapper, "__SNIPPET__", String.trim(snippet))
    end
  end

  @doc "Whether this task's grading requires the sandbox (compile + ExUnit)."
  @spec needs_sandbox?(t()) :: boolean()
  def needs_sandbox?(%__MODULE__{type: type}), do: type in [:write_code, :fix_code, :snippet]

  defp item_test_file(checks, raw_checks) do
    check_tests =
      checks
      |> Enum.with_index(1)
      |> Enum.map(fn {{input_code, expected_code}, i} ->
        """
          test "check #{i}" do
            input = #{input_code}
            assert Micro.solve(input) == (#{expected_code})
          end
        """
      end)

    raw_tests =
      raw_checks
      |> Enum.with_index(1)
      |> Enum.map(fn {body, i} ->
        """
          test "raw check #{i}" do
            #{body}
          end
        """
      end)

    """
    defmodule MicroTest do
      use ExUnit.Case, async: true

    #{Enum.join(check_tests ++ raw_tests, "\n")}
    end
    """
  end

  defp default_graders(:write_code), do: [:ex_unit]
  defp default_graders(:fix_code), do: [:ex_unit]
  defp default_graders(:snippet), do: [:ex_unit]
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
