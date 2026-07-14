defmodule Gauntlet.Model.Adapter do
  @moduledoc """
  Behaviour for LLM completion backends.

  The runner talks only to this interface, so the whole pipeline can be
  exercised without a live model via `Gauntlet.Model.Fake`.
  """

  @typedoc """
  A provider-agnostic completion result.

    * `:content` - the answer text (reasoning/thinking excluded)
    * `:thinking` - reasoning content if the model exposed it, else nil
    * `:usage` - token counts as returned by the endpoint
    * `:finish_reason` - :stop | :length | other atom the provider reports
    * `:latency_ms` - wall time of the request
  """
  @type result :: %{
          content: String.t(),
          thinking: String.t() | nil,
          usage: map(),
          finish_reason: atom() | String.t() | nil,
          latency_ms: non_neg_integer()
        }

  @type message :: %{role: :system | :user | :assistant, content: String.t()}

  @callback complete(Gauntlet.Model.t(), [message()], keyword()) ::
              {:ok, result()} | {:error, term()}
end
