defmodule FrameParser do
  def parse(binary), do: do_parse(binary, [])

  defp do_parse(<<>>, acc), do: {:ok, Enum.reverse(acc)}

  defp do_parse(<<type::8, len::16-big, payload::binary-size(len), rest::binary>>, acc) do
    do_parse(rest, [{type, payload} | acc])
  end

  defp do_parse(rest, _acc), do: {:error, {:incomplete, byte_size(rest)}}

  def encode(frames) do
    for {type, payload} <- frames, into: <<>> do
      <<type::8, byte_size(payload)::16-big, payload::binary>>
    end
  end
end
