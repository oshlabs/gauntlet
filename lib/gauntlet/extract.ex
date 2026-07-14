defmodule Gauntlet.Extract do
  @moduledoc """
  Extract structured answers from model responses.

  Reasoning models often emit exploratory code blocks before the final one,
  so extraction always takes the LAST matching block.
  """

  @doc """
  The last ```elixir fenced code block in the text, or nil.
  A plain ``` fence is accepted as fallback when no ```elixir fence exists.
  """
  @spec code_block(String.t()) :: String.t() | nil
  def code_block(text) when is_binary(text) do
    last_fence(text, ~r/```elixir\s*\n(.*?)```/s) || last_fence(text, ~r/```\s*\n(.*?)```/s)
  end

  @doc """
  The last ```output fenced block (for predict-output tasks), or nil.
  Falls back to any fenced block, then to the trimmed full text.
  """
  @spec output_block(String.t()) :: String.t() | nil
  def output_block(text) when is_binary(text) do
    case last_fence(text, ~r/```output\s*\n(.*?)```/s) || last_fence(text, ~r/```\s*\n(.*?)```/s) do
      nil -> presence(String.trim(text))
      block -> block
    end
  end

  @doc """
  The MCQ answer letter from a final `ANSWER: X` line, or nil.
  """
  @spec mcq_answer(String.t()) :: String.t() | nil
  def mcq_answer(text) when is_binary(text) do
    case Regex.scan(~r/ANSWER:\s*([A-Za-z])/, text) do
      [] -> nil
      matches -> matches |> List.last() |> Enum.at(1) |> String.upcase()
    end
  end

  defp last_fence(text, regex) do
    case Regex.scan(regex, text) do
      [] ->
        nil

      matches ->
        matches
        |> List.last()
        |> Enum.at(1)
        |> String.trim()
        |> presence()
    end
  end

  defp presence(""), do: nil
  defp presence(s), do: s
end
