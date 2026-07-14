defmodule Gauntlet.Store do
  @moduledoc """
  Run directory layout and persistence.

      runs/<stamp>_<model>_<suite>/
        meta.json        reproducibility block
        events.jsonl     one line per LLM request/response
        verdicts.jsonl   one line per verdict (stable downstream interface)
        summary.json     aggregate scores
        report.md        human-readable report
        attempts/        sandbox work dirs (pruned to failures on completion)
  """

  alias Gauntlet.Verdict

  @enforce_keys [:dir]
  defstruct [:dir]

  @type t :: %__MODULE__{dir: String.t()}

  @doc "Create a run directory and write the initial meta.json."
  @spec create(String.t(), String.t(), map(), keyword()) :: t()
  def create(model_name, suite_name, meta, opts \\ []) do
    root = Keyword.get(opts, :runs_dir, "runs")

    stamp =
      DateTime.utc_now()
      |> Calendar.strftime("%Y-%m-%dT%H%M%SZ")

    dir = Path.join(root, "#{stamp}_#{sanitize(model_name)}_#{sanitize(suite_name)}")
    File.mkdir_p!(Path.join(dir, "attempts"))
    store = %__MODULE__{dir: dir}
    write_json(store, "meta.json", Map.put(meta, :run_id, Path.basename(dir)))
    store
  end

  @doc "Append an LLM request/response event."
  @spec append_event(t(), map()) :: :ok
  def append_event(%__MODULE__{} = store, event) do
    append_jsonl(store, "events.jsonl", event)
  end

  @doc "Append a verdict."
  @spec append_verdict(t(), Verdict.t()) :: :ok
  def append_verdict(%__MODULE__{} = store, %Verdict{} = verdict) do
    append_jsonl(store, "verdicts.jsonl", Verdict.to_map(verdict))
  end

  @doc "Write the aggregate summary."
  @spec write_summary(t(), map()) :: :ok
  def write_summary(%__MODULE__{} = store, summary) do
    write_json(store, "summary.json", summary)
  end

  @doc "Write the human-readable report."
  @spec write_report(t(), String.t()) :: :ok
  def write_report(%__MODULE__{} = store, markdown) do
    File.write!(Path.join(store.dir, "report.md"), markdown)
  end

  @doc "Read all verdicts back from a run directory."
  @spec read_verdicts(String.t()) :: [map()]
  def read_verdicts(run_dir) do
    read_jsonl(Path.join(run_dir, "verdicts.jsonl"))
  end

  @doc "Read the meta block of a run directory."
  @spec read_meta(String.t()) :: map()
  def read_meta(run_dir) do
    run_dir |> Path.join("meta.json") |> File.read!() |> Jason.decode!()
  end

  @doc "The work dir for one attempt's sandbox."
  @spec attempt_dir(t(), String.t(), pos_integer(), pos_integer()) :: String.t()
  def attempt_dir(%__MODULE__{} = store, task_id, sample, round) do
    Path.join([store.dir, "attempts", "#{sanitize(task_id)}_s#{sample}_r#{round}"])
  end

  @doc "Working area for the warmed sandbox template of this run."
  @spec work_dir(t()) :: String.t()
  def work_dir(%__MODULE__{dir: dir}), do: dir

  @doc "Delete sandbox dirs of passing attempts, keep failures for debugging."
  @spec prune_attempts(t(), [Verdict.t()]) :: :ok
  def prune_attempts(%__MODULE__{} = store, verdicts) do
    passing =
      verdicts
      |> Enum.filter(&(&1.status == :pass))
      |> MapSet.new(&attempt_dir(store, &1.task_id, &1.sample, &1.round))

    for dir <- passing do
      File.rm_rf!(dir)
    end

    :ok
  end

  defp read_jsonl(path) do
    if File.regular?(path) do
      path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)
    else
      []
    end
  end

  defp append_jsonl(store, file, map) do
    line = Jason.encode!(sanitize_json(map))
    File.write!(Path.join(store.dir, file), line <> "\n", [:append])
  end

  defp write_json(store, file, map) do
    File.write!(Path.join(store.dir, file), Jason.encode!(sanitize_json(map), pretty: true))
  end

  # Tuples/pids etc. inside nested maps would crash Jason — inspect them.
  defp sanitize_json(%_struct{} = struct), do: struct |> Map.from_struct() |> sanitize_json()

  defp sanitize_json(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {k, sanitize_json(v)} end)
  end

  defp sanitize_json(list) when is_list(list), do: Enum.map(list, &sanitize_json/1)

  defp sanitize_json(v)
       when is_binary(v) or is_number(v) or is_boolean(v) or is_atom(v),
       do: v

  defp sanitize_json(v), do: inspect(v)

  defp sanitize(name), do: String.replace(name, ~r/[^A-Za-z0-9._-]/, "-")
end
