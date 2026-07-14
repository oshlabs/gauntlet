list = [104, 105]
IO.inspect(list)

IO.inspect(7 / 2)
IO.inspect(div(7, 2))
IO.inspect(rem(-7, 2))

s = "héllo"
IO.inspect(String.length(s))
IO.inspect(byte_size(s))
IO.inspect(String.slice(s, 1, 2))

IO.inspect("1" <> to_string(2))
IO.inspect(Enum.at([1, 2, 3], -1))

result =
  try do
    String.to_integer("3.5")
  rescue
    ArgumentError -> :bad_arg
  end

IO.inspect(result)

IO.inspect(Enum.zip([1, 2, 3], [:a, :b]))
IO.inspect(if 0, do: :truthy, else: :falsy)
IO.inspect(Keyword.get([a: 1, a: 2], :a))
