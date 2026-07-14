defmodule Gauntlet.Model.ReqLlm do
  @moduledoc """
  Real completion backend over ReqLLM against any OpenAI-compatible endpoint.

  Uses an inline model spec (`%{provider: :openai, id: ..., base_url: ...}`)
  so local endpoints work without an LLMDB catalog entry. ReqLLM decodes
  DeepSeek-style `reasoning`/`reasoning_content` message fields into thinking
  content parts, so `content` here is already free of reasoning text.
  """

  @behaviour Gauntlet.Model.Adapter

  alias Gauntlet.Model

  @impl true
  def complete(%Model{} = model, messages, opts \\ []) do
    context =
      ReqLLM.Context.new(
        Enum.map(messages, fn
          %{role: :system, content: c} -> ReqLLM.Context.system(c)
          %{role: :user, content: c} -> ReqLLM.Context.user(c)
          %{role: :assistant, content: c} -> ReqLLM.Context.assistant(c)
        end)
      )

    gen_opts =
      [
        temperature: model.temperature,
        max_tokens: Keyword.get(opts, :max_tokens, model.max_tokens),
        api_key: Model.api_key(model),
        receive_timeout: model.request_timeout_ms
      ]

    started = System.monotonic_time(:millisecond)

    case ReqLLM.generate_text(req_llm_model(model), context, gen_opts) do
      {:ok, response} ->
        latency = System.monotonic_time(:millisecond) - started

        {:ok,
         %{
           content: ReqLLM.Response.text(response) || "",
           thinking: presence(ReqLLM.Response.thinking(response)),
           usage: response.usage || %{},
           finish_reason: response.finish_reason,
           latency_ms: latency
         }}

      {:error, _} = error ->
        error
    end
  end

  defp req_llm_model(%Model{base_url: nil, model_spec: spec}), do: spec

  defp req_llm_model(%Model{base_url: base_url, model_spec: spec}) do
    {provider, id} = parse_spec(spec)
    ReqLLM.model!(%{provider: provider, id: id, base_url: base_url})
  end

  defp parse_spec(spec) do
    case String.split(spec, ":", parts: 2) do
      [provider, id] -> {String.to_existing_atom(provider), id}
      [id] -> {:openai, id}
    end
  end

  defp presence(nil), do: nil
  defp presence(""), do: nil
  defp presence(s), do: s
end
