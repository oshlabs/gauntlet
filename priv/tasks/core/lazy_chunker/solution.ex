defmodule LazyChunker do
  def by_budget(enum, budget) do
    Stream.chunk_while(
      enum,
      {[], 0},
      fn element, {chunk, sum} ->
        cond do
          chunk == [] ->
            {:cont, {[element], element}}

          sum + element <= budget ->
            {:cont, {[element | chunk], sum + element}}

          true ->
            {:cont, Enum.reverse(chunk), {[element], element}}
        end
      end,
      fn
        {[], _sum} -> {:cont, {[], 0}}
        {chunk, _sum} -> {:cont, Enum.reverse(chunk), {[], 0}}
      end
    )
  end
end
