defmodule Gauntlet.Verdict do
  @moduledoc """
  The graded outcome of one attempt round for one (model, task, sample).
  One JSON line per verdict is appended to `verdicts.jsonl` in the run dir;
  that file is the stable interface everything downstream reads.
  """

  @enforce_keys [:task_id, :model, :sample, :round, :status]
  defstruct task_id: nil,
            model: nil,
            sample: 1,
            round: 1,
            status: nil,
            dimension: nil,
            difficulty: nil,
            weight: 1.0,
            tests: nil,
            subscores: %{},
            usage: %{},
            latency_ms: nil,
            detail: nil

  @type status ::
          :pass
          | :fail
          | :compile_error
          | :timeout
          | :truncated
          | :extraction_failed
          | :llm_error

  @type t :: %__MODULE__{
          task_id: String.t(),
          model: String.t(),
          sample: pos_integer(),
          round: pos_integer(),
          status: status(),
          dimension: atom(),
          difficulty: atom(),
          weight: float(),
          tests: %{total: non_neg_integer(), passed: non_neg_integer()} | nil,
          subscores: map(),
          usage: map(),
          latency_ms: non_neg_integer() | nil,
          detail: String.t() | nil
        }

  @doc "Encode a verdict as a JSON-compatible map."
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = v) do
    v
    |> Map.from_struct()
    |> Map.update!(:detail, &truncate/1)
  end

  defp truncate(nil), do: nil
  defp truncate(s) when byte_size(s) > 8_192, do: binary_slice(s, 0, 8_192) <> "…[truncated]"
  defp truncate(s), do: s
end
