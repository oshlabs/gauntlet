defmodule Gauntlet.Suite do
  @moduledoc """
  A named collection of task packs with per-dimension weights.

  Suites are defined in `priv/tasks/suites.exs` as a map of
  `name => %{packs: [...], weights: %{dimension => weight}}`.

  The suite hash is a sha256 over every file of every included task,
  recorded in run metadata: two runs are only comparable when their
  suite hashes match.
  """

  alias Gauntlet.Task

  @enforce_keys [:name, :tasks, :weights, :hash]
  defstruct [:name, :tasks, :weights, :hash]

  @type t :: %__MODULE__{
          name: String.t(),
          tasks: [Task.t()],
          weights: %{Task.dimension() => number()},
          hash: String.t()
        }

  @doc """
  Load a named suite from the task tree.

  Options:
    * `:tasks_dir` - override the task tree root (default `priv/tasks`)
    * `:only` - keep only tasks whose id contains this string
    * `:tags` - keep only tasks having at least one of these tags
  """
  @spec load(String.t(), keyword()) :: {:ok, t()} | {:error, term()}
  def load(name, opts \\ []) do
    tasks_dir = Keyword.get(opts, :tasks_dir, default_tasks_dir())
    suites = load_suites(tasks_dir)

    case Map.fetch(suites, name) do
      :error ->
        {:error, {:unknown_suite, name, Map.keys(suites)}}

      {:ok, def} ->
        tasks =
          def.packs
          |> Enum.flat_map(&load_pack(tasks_dir, &1))
          |> reject_duplicate_ids!()
          |> filter(opts)

        {:ok,
         %__MODULE__{
           name: name,
           tasks: tasks,
           weights: Map.get(def, :weights, %{}),
           hash: hash_tasks(tasks)
         }}
    end
  end

  @doc "List suite names defined in suites.exs."
  @spec names(keyword()) :: [String.t()]
  def names(opts \\ []) do
    opts |> Keyword.get(:tasks_dir, default_tasks_dir()) |> load_suites() |> Map.keys()
  end

  @doc "The default task tree root inside the gauntlet repo."
  @spec default_tasks_dir() :: String.t()
  def default_tasks_dir do
    Path.join(:code.priv_dir(:gauntlet), "tasks")
  end

  defp load_suites(tasks_dir) do
    path = Path.join(tasks_dir, "suites.exs")

    unless File.exists?(path) do
      raise ArgumentError, "no suites.exs in #{tasks_dir}"
    end

    {suites, _} = Code.eval_file(path)
    suites
  end

  # A pack contains task directories (one full task each) and/or item files
  # (a `<theme>.exs` evaluating to a list of micro-item maps, each becoming
  # one :snippet task).
  defp load_pack(tasks_dir, pack) do
    pack_dir = Path.join(tasks_dir, pack)

    if File.dir?(pack_dir) do
      entries = pack_dir |> File.ls!() |> Enum.sort() |> Enum.map(&Path.join(pack_dir, &1))

      dir_tasks =
        entries
        |> Enum.filter(&File.dir?/1)
        |> Enum.map(&Task.load!/1)

      item_tasks =
        entries
        |> Enum.filter(fn path ->
          String.ends_with?(path, ".exs") and not String.starts_with?(Path.basename(path), "_")
        end)
        |> Enum.flat_map(&load_item_file(pack, &1))

      dir_tasks ++ item_tasks
    else
      []
    end
  end

  defp load_item_file(pack, path) do
    {items, _} = Code.eval_file(path)

    unless is_list(items) do
      raise ArgumentError, "item file #{path} must evaluate to a list of maps"
    end

    tasks = Enum.map(items, &Task.from_item!(pack, path, &1))

    case tasks |> Enum.frequencies_by(& &1.id) |> Enum.filter(fn {_, n} -> n > 1 end) do
      [] -> tasks
      dups -> raise ArgumentError, "duplicate item ids in #{path}: #{inspect(dups)}"
    end
  end

  defp filter(tasks, opts) do
    tasks
    |> then(fn ts ->
      case Keyword.get(opts, :only) do
        nil -> ts
        substr -> Enum.filter(ts, &String.contains?(&1.id, substr))
      end
    end)
    |> then(fn ts ->
      case Keyword.get(opts, :tags) do
        nil -> ts
        tags -> Enum.filter(ts, fn t -> Enum.any?(t.tags, &(&1 in tags)) end)
      end
    end)
  end

  defp reject_duplicate_ids!(tasks) do
    case tasks |> Enum.frequencies_by(& &1.id) |> Enum.filter(fn {_, n} -> n > 1 end) do
      [] -> tasks
      dups -> raise ArgumentError, "duplicate task ids across packs: #{inspect(dups)}"
    end
  end

  # sha256 over sorted (task-relative path, file sha) pairs of all task files.
  # Item-file tasks share one source file; each contributes it under its own id.
  defp hash_tasks(tasks) do
    digest =
      tasks
      |> Enum.sort_by(& &1.id)
      |> Enum.flat_map(fn task ->
        task.dir
        |> task_files()
        |> Enum.sort()
        |> Enum.map(fn path ->
          rel = task.id <> "/" <> Path.relative_to(path, task.dir)
          file_sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
          rel <> ":" <> file_sha
        end)
      end)
      |> Enum.join("\n")
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    "sha256:" <> digest
  end

  defp task_files(dir) do
    if File.dir?(dir), do: files_recursive(dir), else: [dir]
  end

  defp files_recursive(dir) do
    dir
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      path = Path.join(dir, entry)

      cond do
        File.dir?(path) -> files_recursive(path)
        File.regular?(path) -> [path]
        true -> []
      end
    end)
  end
end
