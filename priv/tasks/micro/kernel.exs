# Kernel micro items: Kernel functions/operators, special forms & control flow,
# sigils. Elixir 1.19 semantics, all checks deterministic.
[
  # ── Guards as expressions ────────────────────────────────────────────────
  %{
    id: "kernel/is-atom-nil",
    prompt: ~S|`input` is an arbitrary term. Return the 2-tuple {whether input is an atom, whether input is nil}, both booleans.|,
    solution: ~S|{is_atom(input), is_nil(input)}|,
    checks: [
      {~S|nil|, ~S|{true, true}|},
      {~S|:ok|, ~S|{true, false}|},
      {~S|"a"|, ~S|{false, false}|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/is-binary",
    prompt: ~S|`input` is an arbitrary term. Return true when input is a binary (a byte-aligned bitstring), false otherwise.|,
    solution: ~S|is_binary(input)|,
    checks: [
      {~S|"héllo"|, ~S|true|},
      {~S|~c"abc"|, ~S|false|},
      {~S|<<1::size(4)>>|, ~S|false|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/is-number-kinds",
    prompt: ~S|`input` is an arbitrary term. Return the 3-tuple {whether input is an integer, whether input is a float, whether input is a number}, all booleans.|,
    solution: ~S|{is_integer(input), is_float(input), is_number(input)}|,
    checks: [
      {~S|1|, ~S|{true, false, true}|},
      {~S|1.5|, ~S|{false, true, true}|},
      {~S|"1"|, ~S|{false, false, false}|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/is-list-tuple",
    prompt: ~S|`input` is an arbitrary term. Return the 2-tuple {whether input is a list, whether input is a tuple}, both booleans.|,
    solution: ~S|{is_list(input), is_tuple(input)}|,
    checks: [
      {~S|[1]|, ~S|{true, false}|},
      {~S|{1, 2}|, ~S|{false, true}|},
      {~S|"ab"|, ~S|{false, false}|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/is-map",
    prompt: ~S|`input` is an arbitrary term. Return true when input is a map according to Elixir's type check, false otherwise.|,
    solution: ~S|is_map(input)|,
    checks: [
      {~S|%{a: 1}|, ~S|true|},
      {~S|MapSet.new([1])|, ~S|true|},
      {~S|[a: 1]|, ~S|false|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/is-map-key",
    prompt: ~S|`input` is a 2-tuple {map, key}. Return true when key is present in map (key presence, regardless of the stored value), false otherwise.|,
    solution: ~S|is_map_key(elem(input, 0), elem(input, 1))|,
    checks: [
      {~S|{%{a: nil}, :a}|, ~S|true|},
      {~S|{%{}, :a}|, ~S|false|},
      {~S|{%{"x" => 1}, "x"}|, ~S|true|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/is-function-arity",
    prompt: ~S|`input` is an arbitrary term. Return true only when input is a function that accepts exactly 2 arguments; return false for functions of any other arity and for non-functions.|,
    solution: ~S|is_function(input, 2)|,
    checks: [
      {~S|fn a, b -> {a, b} end|, ~S|true|},
      {~S|fn a -> a end|, ~S|false|},
      {~S|:not_a_fun|, ~S|false|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/is-struct",
    prompt: ~S|`input` is an arbitrary term. Return the 2-tuple {whether input is a struct of any kind, whether input is specifically a Date struct}, both booleans.|,
    solution: ~S|{is_struct(input), is_struct(input, Date)}|,
    checks: [
      {~S|~D[2024-01-05]|, ~S|{true, true}|},
      {~S|~T[12:30:00]|, ~S|{true, false}|},
      {~S|%{}|, ~S|{false, false}|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },

  # ── Kernel functions & operators ─────────────────────────────────────────
  %{
    id: "kernel/abs",
    prompt: ~S|`input` is an integer. Return its absolute value as an integer.|,
    solution: ~S|abs(input)|,
    checks: [
      {~S|-5|, ~S|5|},
      {~S|0|, ~S|0|},
      {~S|7|, ~S|7|}
    ],
    tags: [:kernel, :trap],
    difficulty: :easy
  },
  %{
    id: "kernel/min-max",
    prompt: ~S|`input` is a 2-tuple of terms {a, b}. Return the 2-tuple {smaller, larger} according to Elixir's term ordering.|,
    solution: ~S|{min(elem(input, 0), elem(input, 1)), max(elem(input, 0), elem(input, 1))}|,
    checks: [
      {~S|{3, 7}|, ~S|{3, 7}|},
      {~S|{:a, 1}|, ~S|{1, :a}|},
      {~S|{-1, -5}|, ~S|{-5, -1}|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/hd-tl",
    prompt: ~S|`input` is a non-empty list. Return the 2-tuple {first element, list of all remaining elements}.|,
    solution: ~S|{hd(input), tl(input)}|,
    checks: [
      {~S|[1, 2, 3]|, ~S|{1, [2, 3]}|},
      {~S|[1]|, ~S|{1, []}|},
      {~S|[[1], 2]|, ~S|{[1], [2]}|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/tuple-elem",
    prompt: ~S|`input` is a 2-tuple {tuple, index} where index is a zero-based integer. Return the element of tuple found at index.|,
    solution: ~S|elem(elem(input, 0), elem(input, 1))|,
    checks: [
      {~S|{{:a, :b, :c}, 1}|, ~S|:b|},
      {~S|{{:only}, 0}|, ~S|:only|},
      {~S|{{1, 2, 3}, 2}|, ~S|3|}
    ],
    tags: [:kernel, :trap],
    difficulty: :easy
  },
  %{
    id: "kernel/put-elem",
    prompt: ~S|`input` is a 3-tuple {tuple, index, value} where index is zero-based. Return a copy of tuple with the element at index replaced by value.|,
    solution: ~S|put_elem(elem(input, 0), elem(input, 1), elem(input, 2))|,
    checks: [
      {~S|{{1, 2, 3}, 1, :x}|, ~S|{1, :x, 3}|},
      {~S|{{:a}, 0, :b}|, ~S|{:b}|},
      {~S|{{1, 2}, 1, nil}|, ~S|{1, nil}|}
    ],
    tags: [:kernel, :trap],
    difficulty: :medium
  },
  %{
    id: "kernel/tuple-size",
    prompt: ~S|`input` is a tuple. Return the number of elements it holds, as an integer.|,
    solution: ~S|tuple_size(input)|,
    checks: [
      {~S|{1, 2, 3}|, ~S|3|},
      {~S|{}|, ~S|0|}
    ],
    tags: [:kernel, :trap],
    difficulty: :easy
  },
  %{
    id: "kernel/map-size",
    prompt: ~S|`input` is a map. Return the number of key-value entries it holds, as an integer.|,
    solution: ~S|map_size(input)|,
    checks: [
      {~S|%{a: 1, b: 2}|, ~S|2|},
      {~S|%{}|, ~S|0|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/byte-bit-size",
    prompt: ~S|`input` is a bitstring. Return the 2-tuple {size in bytes, size in bits}, where the byte count rounds up when input is not byte-aligned.|,
    solution: ~S|{byte_size(input), bit_size(input)}|,
    checks: [
      {~S|"é"|, ~S|{2, 16}|},
      {~S|<<1::size(4)>>|, ~S|{1, 4}|},
      {~S|<<>>|, ~S|{0, 0}|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/length",
    prompt: ~S|`input` is a proper list. Return the number of elements it holds, as an integer.|,
    solution: ~S|length(input)|,
    checks: [
      {~S|[1, 2, 3]|, ~S|3|},
      {~S|[]|, ~S|0|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/not-in",
    prompt: ~S|`input` is a 2-tuple {x, list}. Return true when x is not a member of list, false when it is a member.|,
    solution: ~S|elem(input, 0) not in elem(input, 1)|,
    checks: [
      {~S|{4, [1, 2, 3]}|, ~S|true|},
      {~S|{2, [1, 2, 3]}|, ~S|false|},
      {~S|{:a, []}|, ~S|true|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/to-string",
    prompt: ~S|`input` is an atom, integer, or float. Return its string representation — the same conversion string interpolation performs.|,
    solution: ~S|to_string(input)|,
    checks: [
      {~S|:hello|, ~S|"hello"|},
      {~S|42|, ~S|"42"|},
      {~S|1.5|, ~S|"1.5"|}
    ],
    tags: [:kernel],
    difficulty: :easy
  },
  %{
    id: "kernel/inspect-basic",
    prompt: ~S|`input` is an atom, string, or integer. Return the string that Elixir's standard inspection (the representation shown by IEx) produces for it.|,
    solution: ~S|inspect(input)|,
    checks: [
      {~S|:ok|, ~S|":ok"|},
      {~S|"a"|, ~S|"\"a\""|},
      {~S|42|, ~S|"42"|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/inspect-charlists-option",
    prompt: ~S|`input` is a list of integers (possibly a charlist). Return the inspection string that always renders it as a plain list of integers, never as a charlist.|,
    solution: ~S|inspect(input, charlists: :as_lists)|,
    checks: [
      {~S|~c"abc"|, ~S|"[97, 98, 99]"|},
      {~S|[10]|, ~S|"[10]"|},
      {~S|[]|, ~S|"[]"|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/struct-builder",
    prompt: ~S|`input` is a keyword list of URI struct fields (for example host and port). Return a %URI{} struct with those fields set and every other field left at its default.|,
    solution: ~S|struct(URI, input)|,
    checks: [
      {~S|[host: "example.com"]|, ~S|%URI{host: "example.com"}|},
      {~S|[host: "x", port: 8080]|, ~S|%URI{host: "x", port: 8080}|},
      {~S|[]|, ~S|%URI{}|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/then-tap",
    prompt: ~S|`input` is an integer. Return the 2-tuple whose first element is input piped through then/2 with a doubling function, and whose second element is input piped through tap/2 with the same doubling function.|,
    solution: ~S|{then(input, &(&1 * 2)), tap(input, &(&1 * 2))}|,
    checks: [
      {~S|3|, ~S|{6, 3}|},
      {~S|0|, ~S|{0, 0}|},
      {~S|-1|, ~S|{-2, -1}|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/eq-vs-strict",
    prompt: ~S|`input` is a 2-tuple {a, b}. Return the 2-tuple {a compared to b with value equality (==), a compared to b with strict equality (===)}, both booleans.|,
    solution: ~S|{elem(input, 0) == elem(input, 1), elem(input, 0) === elem(input, 1)}|,
    checks: [
      {~S|{1, 1.0}|, ~S|{true, false}|},
      {~S|{1, 1}|, ~S|{true, true}|},
      {~S|{:x, :x}|, ~S|{true, true}|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/strict-and",
    prompt: ~S|`input` is an arbitrary term. Return the result of the strict boolean expression input and true. For input true the result is true, for input false it is false, and for any non-boolean input evaluating the expression must raise BadBooleanError.|,
    solution: ~S|input and true|,
    checks: [
      {~S|true|, ~S|true|},
      {~S|false|, ~S|false|}
    ],
    raw_checks: [
      ~S|assert_raise BadBooleanError, fn -> Micro.solve(1) end|
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/truthy-and-or",
    prompt: ~S"""
    `input` is an arbitrary term. Return the 2-tuple {input && :x, input || :y} using the truthiness-based operators. Mind exactly which values Elixir treats as falsy.
    """,
    solution: ~S"""
    {input && :x, input || :y}
    """,
    checks: [
      {~S|0|, ~S|{:x, 0}|},
      {~S|nil|, ~S|{nil, :y}|},
      {~S|false|, ~S|{false, :y}|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/term-order",
    prompt: ~S|`input` is a 2-tuple of terms {a, b}, possibly of different types. Return true when a sorts strictly before b in Elixir's term ordering, false otherwise.|,
    solution: ~S|elem(input, 0) < elem(input, 1)|,
    checks: [
      {~S|{1, :a}|, ~S|true|},
      {~S|{%{}, []}|, ~S|true|},
      {~S|{"z", :a}|, ~S|false|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/div-rem-slash",
    prompt: ~S|`input` is a 2-tuple of integers {a, b} with b nonzero. Return the 3-tuple {integer division of a by b truncated toward zero, the matching remainder (its sign follows a), a divided by b with the / operator (always a float)}.|,
    solution: ~S|{div(elem(input, 0), elem(input, 1)), rem(elem(input, 0), elem(input, 1)), elem(input, 0) / elem(input, 1)}|,
    checks: [
      {~S|{7, 2}|, ~S|{3, 1, 3.5}|},
      {~S|{-5, 3}|, ~S|{-1, -2, -5 / 3}|},
      {~S|{4, 2}|, ~S|{2, 0, 2.0}|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/integer-mod",
    prompt: ~S|`input` is a 2-tuple of integers {a, b} with b positive. Return the floored modulo of a by b — the result whose sign follows the divisor, so here it always lands in the range 0 to b - 1.|,
    solution: ~S|Integer.mod(elem(input, 0), elem(input, 1))|,
    checks: [
      {~S|{-5, 3}|, ~S|1|},
      {~S|{5, 3}|, ~S|2|},
      {~S|{-6, 3}|, ~S|0|}
    ],
    tags: [:kernel, :integer],
    difficulty: :hard
  },
  %{
    id: "kernel/round-trunc-floor-ceil",
    prompt: ~S|`input` is a float. Return the 4-tuple of integers {input rounded to the nearest integer with halves rounding away from zero, input truncated toward zero, the floor of input, the ceiling of input}.|,
    solution: ~S|{round(input), trunc(input), floor(input), ceil(input)}|,
    checks: [
      {~S|2.5|, ~S|{3, 2, 2, 3}|},
      {~S|-2.5|, ~S|{-3, -2, -3, -2}|},
      {~S|2.0|, ~S|{2, 2, 2, 2}|}
    ],
    tags: [:kernel],
    difficulty: :hard
  },
  %{
    id: "kernel/apply-mfa",
    prompt: ~S|`input` is a 3-tuple {module, function_name, argument_list}. Call that function dynamically and return its result.|,
    solution: ~S|apply(elem(input, 0), elem(input, 1), elem(input, 2))|,
    checks: [
      {~S|{String, :upcase, ["abc"]}|, ~S|"ABC"|},
      {~S|{Enum, :sum, [[1, 2, 3]]}|, ~S|6|},
      {~S|{Kernel, :abs, [-3]}|, ~S|3|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/function-exported",
    prompt: ~S|`input` is a 3-tuple {module, function_name, arity} where module is an already-loaded Erlang module. Return true when the module exports a function with that name and arity, false otherwise.|,
    solution: ~S|function_exported?(elem(input, 0), elem(input, 1), elem(input, 2))|,
    checks: [
      {~S|{:erlang, :length, 1}|, ~S|true|},
      {~S|{:erlang, :not_a_fun, 1}|, ~S|false|},
      {~S|{:erlang, :length, 2}|, ~S|false|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/match-count",
    prompt: ~S|`input` is a list of tuples. Return how many elements are 2-tuples whose first element is the atom :ok (the second element may be anything).|,
    solution: ~S|Enum.count(input, &match?({:ok, _}, &1))|,
    checks: [
      {~S|[{:ok, 1}, {:error, :x}, {:ok, :y}]|, ~S|2|},
      {~S|[{:ok, 1, 2}]|, ~S|0|},
      {~S|[]|, ~S|0|}
    ],
    tags: [:kernel],
    difficulty: :medium
  },
  %{
    id: "kernel/list-concat",
    prompt: ~S|`input` is a 2-tuple of lists. Return a single list holding the elements of the first list followed by the elements of the second, in order.|,
    solution: ~S|elem(input, 0) ++ elem(input, 1)|,
    checks: [
      {~S|{[1, 2], [3]}|, ~S|[1, 2, 3]|},
      {~S|{[], [1]}|, ~S|[1]|},
      {~S|{[1], []}|, ~S|[1]|}
    ],
    tags: [:kernel, :trap],
    difficulty: :easy
  },

  # ── Special forms & control flow ─────────────────────────────────────────
  %{
    id: "kernel/case-guards",
    prompt: ~S|`input` is an integer. Return :negative when input is less than 0, :zero when it equals 0, and :positive otherwise.|,
    solution: ~S|
case input do
  n when n < 0 -> :negative
  0 -> :zero
  _ -> :positive
end
|,
    checks: [
      {~S|-5|, ~S|:negative|},
      {~S|0|, ~S|:zero|},
      {~S|3|, ~S|:positive|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },
  %{
    id: "kernel/cond-fizzbuzz",
    prompt: ~S|`input` is a positive integer. Return :fizzbuzz when it is divisible by 15, :fizz when divisible by 3 but not 15, :buzz when divisible by 5 but not 15, and the integer itself otherwise.|,
    solution: ~S|
cond do
  rem(input, 15) == 0 -> :fizzbuzz
  rem(input, 3) == 0 -> :fizz
  rem(input, 5) == 0 -> :buzz
  true -> input
end
|,
    checks: [
      {~S|15|, ~S|:fizzbuzz|},
      {~S|10|, ~S|:buzz|},
      {~S|7|, ~S|7|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },
  %{
    id: "kernel/if-else-value",
    prompt: ~S|`input` is an integer. Return :big when input is greater than 10, otherwise return :small.|,
    solution: ~S|if input > 10, do: :big, else: :small|,
    checks: [
      {~S|11|, ~S|:big|},
      {~S|10|, ~S|:small|},
      {~S|-1|, ~S|:small|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },
  %{
    id: "kernel/if-without-else",
    prompt: ~S|`input` is an integer. Return the value of an if expression whose condition is input > 10, whose do branch evaluates to :big, and which has no else branch at all.|,
    solution: ~S|if input > 10, do: :big|,
    checks: [
      {~S|11|, ~S|:big|},
      {~S|10|, ~S|nil|},
      {~S|3|, ~S|nil|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/with-two-clauses",
    prompt: ~S|`input` is a map. When both keys :a and :b are present, return the sum of their values; when either key is missing, return :missing.|,
    solution: ~S|
with {:ok, a} <- Map.fetch(input, :a),
     {:ok, b} <- Map.fetch(input, :b) do
  a + b
else
  _ -> :missing
end
|,
    checks: [
      {~S|%{a: 1, b: 2}|, ~S|3|},
      {~S|%{a: 1}|, ~S|:missing|},
      {~S|%{}|, ~S|:missing|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/with-fallthrough",
    prompt: ~S|`input` is a map. Use Map.fetch to look up the key :k. When the key is present, return double its value. When it is absent, the whole expression must evaluate to exactly what Map.fetch returned — the atom :error. Do not add an else branch.|,
    solution: ~S|with {:ok, v} <- Map.fetch(input, :k), do: v * 2|,
    checks: [
      {~S|%{k: 5}|, ~S|10|},
      {~S|%{}|, ~S|:error|},
      {~S|%{k: 0}|, ~S|0|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :hard
  },
  %{
    id: "kernel/with-guard-nonmatch",
    prompt: ~S|`input` is a map. Look up the key :k with Map.fetch. When the key is present and its value is an integer, return the value times 2. When the key is present with a non-integer value, return the fetch result itself, i.e. {:ok, value}. When the key is absent, return :error.|,
    solution: ~S|with {:ok, n} when is_integer(n) <- Map.fetch(input, :k), do: n * 2|,
    checks: [
      {~S|%{k: 5}|, ~S|10|},
      {~S|%{k: "x"}|, ~S|{:ok, "x"}|},
      {~S|%{}|, ~S|:error|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :hard
  },
  %{
    id: "kernel/for-squares",
    prompt: ~S|`input` is a list of integers. Return the list of their squares, in order.|,
    solution: ~S|for x <- input, do: x * x|,
    checks: [
      {~S|[1, 2, 3]|, ~S|[1, 4, 9]|},
      {~S|[-2]|, ~S|[4]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },
  %{
    id: "kernel/for-filter-even",
    prompt: ~S|`input` is a list of non-negative integers. Return the list of only the even elements, keeping their order.|,
    solution: ~S|for x <- input, rem(x, 2) == 0, do: x|,
    checks: [
      {~S|[1, 2, 3, 4]|, ~S|[2, 4]|},
      {~S|[1, 3]|, ~S|[]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },
  %{
    id: "kernel/for-into-map",
    prompt: ~S|`input` is a keyword list with unique atom keys and integer values. Return a map with the same keys where each value is the square of the original value.|,
    solution: ~S|for {k, v} <- input, into: %{}, do: {k, v * v}|,
    checks: [
      {~S|[a: 2, b: 3]|, ~S|%{a: 4, b: 9}|},
      {~S|[z: 0]|, ~S|%{z: 0}|},
      {~S|[]|, ~S|%{}|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/for-into-string",
    prompt: ~S|`input` is a list of Unicode codepoints (integers). Return the UTF-8 string built from those codepoints, in order.|,
    solution: ~S|for c <- input, into: "", do: <<c::utf8>>|,
    checks: [
      {~S|[104, 105]|, ~S|"hi"|},
      {~S|[233]|, ~S|"é"|},
      {~S|[]|, ~S|""|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/for-into-mapset",
    prompt: ~S|`input` is a list of integers. Return a MapSet containing each element doubled.|,
    solution: ~S|for x <- input, into: MapSet.new(), do: x * 2|,
    checks: [
      {~S|[1, 2, 2]|, ~S|MapSet.new([2, 4])|},
      {~S|[0]|, ~S|MapSet.new([0])|},
      {~S|[]|, ~S|MapSet.new()|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/for-uniq",
    prompt: ~S|`input` is a list of integers. Using a for comprehension with the uniq: true option, return each element doubled, with duplicate results removed and first-occurrence order kept.|,
    solution: ~S|for x <- input, uniq: true, do: x * 2|,
    checks: [
      {~S|[1, 1, 2]|, ~S|[2, 4]|},
      {~S|[3, 1, 3]|, ~S|[6, 2]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/for-reduce",
    prompt: ~S|`input` is a list of integers. Using a for comprehension with the reduce: option and an initial accumulator of 0, return the sum of all elements (an integer).|,
    solution: ~S|
for x <- input, reduce: 0 do
  acc -> acc + x
end
|,
    checks: [
      {~S|[1, 2, 3]|, ~S|6|},
      {~S|[-1, 1]|, ~S|0|},
      {~S|[]|, ~S|0|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/for-nested",
    prompt: ~S|`input` is a 2-tuple of lists {xs, ys}. Return the list of all {x, y} pairs with x taken from xs and y from ys, in nested-loop order where x varies slowest.|,
    solution: ~S|for x <- elem(input, 0), y <- elem(input, 1), do: {x, y}|,
    checks: [
      {~S|{[1, 2], [:a, :b]}|, ~S|[{1, :a}, {1, :b}, {2, :a}, {2, :b}]|},
      {~S|{[], [1, 2]}|, ~S|[]|},
      {~S|{[1], []}|, ~S|[]|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/for-bitstring",
    prompt: ~S|`input` is a binary. Return a new binary of the same length where every byte equals the original byte plus 1, keeping only the low 8 bits (so 255 wraps to 0).|,
    solution: ~S|for <<b <- input>>, into: "", do: <<b + 1>>|,
    checks: [
      {~S|"abc"|, ~S|"bcd"|},
      {~S|<<255>>|, ~S|<<0>>|},
      {~S|""|, ~S|""|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :hard
  },
  %{
    id: "kernel/pin-count",
    prompt: ~S|`input` is a 2-tuple {x, list}. Return the number of elements of list that are exactly equal to x, as an integer.|,
    solution: ~S|then(input, fn {x, list} -> Enum.count(list, &match?(^x, &1)) end)|,
    checks: [
      {~S|{2, [1, 2, 2, 3]}|, ~S|2|},
      {~S|{:a, []}|, ~S|0|},
      {~S|{nil, [nil, false]}|, ~S|1|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/if-scope",
    prompt: ~S|`input` is an integer. A block binds x = input, then runs an if whose condition is_integer(input) is true and whose body rebinds x to x + 1, and finally the block returns x from outside the if. Return the value this whole block evaluates to, following Elixir's scoping rules for rebinding inside if.|,
    solution: ~S|
x = input

_ = if is_integer(input) do
  x = x + 1
  x
end

x
|,
    checks: [
      {~S|5|, ~S|5|},
      {~S|0|, ~S|0|},
      {~S|-3|, ~S|-3|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :medium
  },
  %{
    id: "kernel/destructure-tuple",
    prompt: ~S|`input` is a 2-tuple of integers {a, b}. Return b minus a.|,
    solution: ~S|
{a, b} = input
b - a
|,
    checks: [
      {~S|{1, 5}|, ~S|4|},
      {~S|{3, 3}|, ~S|0|},
      {~S|{-2, -5}|, ~S|-3|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },
  %{
    id: "kernel/destructure-list",
    prompt: ~S|`input` is a list of integers with at least two elements. Return the 2-tuple {sum of the first two elements, list of all elements after the first two}.|,
    solution: ~S"""
    [a, b | rest] = input
    {a + b, rest}
    """,
    checks: [
      {~S|[1, 2, 3, 4]|, ~S|{3, [3, 4]}|},
      {~S|[1, 2]|, ~S|{3, []}|},
      {~S|[-1, 1, 0]|, ~S|{0, [0]}|}
    ],
    tags: [:kernel, :special_form],
    difficulty: :easy
  },

  # ── Sigils ───────────────────────────────────────────────────────────────
  %{
    id: "kernel/sigil-w",
    prompt: ~S|`input` is a string. Return the list of strings that the ~w word-list sigil produces for the words red green blue, with input appended as the final element.|,
    solution: ~S|~w(red green blue) ++ [input]|,
    checks: [
      {~S|"x"|, ~S|["red", "green", "blue", "x"]|},
      {~S|""|, ~S|["red", "green", "blue", ""]|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/sigil-w-atoms",
    prompt: ~S|`input` is an arbitrary term. Return whether input is a member of the list that the ~w sigil produces for the words ok error timeout when the atom modifier is applied.|,
    solution: ~S|input in ~w(ok error timeout)a|,
    checks: [
      {~S|:ok|, ~S|true|},
      {~S|"ok"|, ~S|false|},
      {~S|:nope|, ~S|false|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :medium
  },
  %{
    id: "kernel/sigil-c-charlist",
    prompt: ~S|`input` is an integer codepoint. Return the charlist containing the two codepoints of "ab" followed by input — a plain list of three integers.|,
    solution: ~S|~c"ab" ++ [input]|,
    checks: [
      {~S|99|, ~S|[97, 98, 99]|},
      {~S|33|, ~S|[97, 98, 33]|}
    ],
    tags: [:kernel, :sigil, :drift],
    difficulty: :medium
  },
  %{
    id: "kernel/sigil-s-interpolating",
    prompt: ~S|`input` is an integer. Return the string produced by the sigil expression ~s(total: #{input + 1}).|,
    solution: ~S|~s(total: #{input + 1})|,
    checks: [
      {~S|1|, ~S|"total: 2"|},
      {~S|41|, ~S|"total: 42"|},
      {~S|-1|, ~S|"total: 0"|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/sigil-s-raw",
    prompt: ~S|`input` is a string. Return the string value of the sigil expression ~S(x: #{y}) with input appended to the end. Recall how the uppercase ~S sigil treats interpolation.|,
    solution: ~S|~S(x: #{y}) <> input|,
    checks: [
      {~S|""|, ~S|"x: \#{y}"|},
      {~S|"!"|, ~S|"x: \#{y}!"|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :hard
  },
  %{
    id: "kernel/sigil-d-date",
    prompt: ~S|`input` is a Date struct. Return true when it is exactly January 5, 2024, false otherwise.|,
    solution: ~S|input == ~D[2024-01-05]|,
    checks: [
      {~S|~D[2024-01-05]|, ~S|true|},
      {~S|~D[2024-01-06]|, ~S|false|},
      {~S|~D[2023-01-05]|, ~S|false|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/sigil-t-time",
    prompt: ~S|`input` is a Time struct with no fractional seconds. Return true when it is exactly 12:30:00, false otherwise.|,
    solution: ~S|input == ~T[12:30:00]|,
    checks: [
      {~S|~T[12:30:00]|, ~S|true|},
      {~S|~T[00:00:00]|, ~S|false|},
      {~S|~T[12:30:01]|, ~S|false|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/sigil-n-naive",
    prompt: ~S|`input` is a NaiveDateTime struct with no fractional seconds. Return true when it is exactly 12:30:00 on January 5, 2024, false otherwise.|,
    solution: ~S|input == ~N[2024-01-05 12:30:00]|,
    checks: [
      {~S|~N[2024-01-05 12:30:00]|, ~S|true|},
      {~S|~N[2024-01-05 12:30:01]|, ~S|false|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/sigil-u-datetime",
    prompt: ~S|`input` is a DateTime struct in UTC with no fractional seconds. Return true when it is exactly 12:30:00 UTC on January 5, 2024, false otherwise.|,
    solution: ~S|input == ~U[2024-01-05 12:30:00Z]|,
    checks: [
      {~S|~U[2024-01-05 12:30:00Z]|, ~S|true|},
      {~S|~U[2024-01-05 12:30:01Z]|, ~S|false|},
      {~S|~U[1970-01-01 00:00:00Z]|, ~S|false|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :medium
  },
  %{
    id: "kernel/sigil-r-digits",
    prompt: ~S|`input` is a string with no newlines. Return true when input consists entirely of one or more ASCII digits, false otherwise — including false for the empty string.|,
    solution: ~S|input =~ ~r/^\d+$/|,
    checks: [
      {~S|"123"|, ~S|true|},
      {~S|"12a"|, ~S|false|},
      {~S|""|, ~S|false|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/regex-caseless",
    prompt: ~S|`input` is a string. Return true when input contains the word hello in any letter casing, false otherwise.|,
    solution: ~S|input =~ ~r/hello/i|,
    checks: [
      {~S|"say HELLO!"|, ~S|true|},
      {~S|"help"|, ~S|false|},
      {~S|"Hello there"|, ~S|true|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  },
  %{
    id: "kernel/codepoint-question-mark",
    prompt: ~S|`input` is a non-negative integer. Return the codepoint of the lowercase letter a plus input, as an integer.|,
    solution: ~S|?a + input|,
    checks: [
      {~S|0|, ~S|97|},
      {~S|1|, ~S|98|},
      {~S|25|, ~S|122|}
    ],
    tags: [:kernel, :sigil],
    difficulty: :easy
  }
]
