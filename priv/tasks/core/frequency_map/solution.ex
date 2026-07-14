defmodule FrequencyMap do
  def words(text) do
    ~r/[\p{L}\p{N}]+(?:'[\p{L}\p{N}]+)*/u
    |> Regex.scan(String.downcase(text))
    |> List.flatten()
    |> Enum.frequencies()
  end
end
