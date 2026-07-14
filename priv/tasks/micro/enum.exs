# Micro items: Enum / Stream / capture syntax (Elixir 1.19).
# See AUTHORING.md for the format. Exactly 62 items, ids all "enum/...".
#
# Sigil delimiters vary because ~S{} does not nest braces: strings containing
# `{`/`}` use ~S"..." (no quotes inside) or ~S(...) (quotes but no parens).

[
  # ── Enum: transform ──────────────────────────────────────────────────────
  %{
    id: "enum/double",
    prompt: ~S{`input` is a list of numbers. Return a list with every value doubled, in the same order.},
    solution: ~S{Enum.map(input, &(&1 * 2))},
    checks: [
      {~S{[1, 2, 3]}, ~S{[2, 4, 6]}},
      {~S{[-1, 0]}, ~S{[-2, 0]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/keep-even",
    prompt: ~S{`input` is a list of integers. Return a list containing only the even ones, preserving order.},
    solution: ~S{Enum.filter(input, &(rem(&1, 2) == 0))},
    checks: [
      {~S{[1, 2, 3, 4]}, ~S{[2, 4]}},
      {~S{[1, 3, 5]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/sum-of-squares",
    prompt: ~S{`input` is a list of integers. Return the sum of the squares of all elements (an integer; 0 for an empty list).},
    solution: ~S{Enum.reduce(input, 0, fn x, acc -> x * x + acc end)},
    checks: [
      {~S{[1, 2, 3]}, ~S{14}},
      {~S{[-2]}, ~S{4}},
      {~S{[]}, ~S{0}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/sum-until-negative",
    prompt: ~S{`input` is a list of integers. Walk it from the left, summing elements, and stop as soon as you hit a negative number (the negative number itself and everything after it are ignored). Return the sum (0 for an empty list or when the first element is negative).},
    solution: ~S"Enum.reduce_while(input, 0, fn x, acc -> if x < 0, do: {:halt, acc}, else: {:cont, acc + x} end)",
    checks: [
      {~S{[1, 2, -1, 5]}, ~S{3}},
      {~S{[-1, 10]}, ~S{0}},
      {~S{[]}, ~S{0}}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/count-strings",
    prompt: ~S{`input` is a list of mixed terms. Return how many of them are strings (Elixir binaries), as an integer.},
    solution: ~S{Enum.count(input, &is_binary/1)},
    checks: [
      {~S{["a", 1, :b, "c"]}, ~S{2}},
      {~S{[1, :a]}, ~S{0}},
      {~S{[]}, ~S{0}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/product",
    prompt: ~S{`input` is a list of integers. Return the product of all elements (an integer). The product of an empty list is 1.},
    solution: ~S{Enum.product(input)},
    checks: [
      {~S{[2, 3, 4]}, ~S{24}},
      {~S{[5]}, ~S{5}},
      {~S{[]}, ~S{1}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/min-or-zero",
    prompt: ~S{`input` is a list of integers. Return the smallest element; if the list is empty, return 0 instead of raising.},
    solution: ~S{Enum.min(input, fn -> 0 end)},
    checks: [
      {~S{[3, 1, 2]}, ~S{1}},
      {~S{[-5, 7]}, ~S{-5}},
      {~S{[]}, ~S{0}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/max-by-score",
    prompt: ~S"`input` is a nonempty list of `{name, score}` tuples where score is an integer. Return the tuple with the highest score; if several tie for highest, return the first of them.",
    solution: ~S{Enum.max_by(input, &elem(&1, 1))},
    checks: [
      {~S([{"a", 3}, {"b", 7}, {"c", 5}]), ~S({"b", 7})},
      {~S([{"a", 3}, {"b", 7}, {"c", 7}]), ~S({"b", 7})},
      {~S([{"x", 1}]), ~S({"x", 1})}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/sort-dates-desc",
    prompt: ~S{`input` is a list of `Date` structs. Return them sorted chronologically newest-first. The ordering must be by actual calendar date, not by structural term comparison.},
    solution: ~S"Enum.sort(input, {:desc, Date})",
    checks: [
      {~S{[~D[2023-12-31], ~D[2024-01-02], ~D[2023-05-10]]}, ~S{[~D[2024-01-02], ~D[2023-12-31], ~D[2023-05-10]]}},
      {~S{[~D[2024-01-02], ~D[2023-12-31]]}, ~S{[~D[2024-01-02], ~D[2023-12-31]]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/sort-by-length",
    prompt: ~S{`input` is a list of strings. Return them sorted by string length, shortest first; strings with equal length keep their original relative order.},
    solution: ~S{Enum.sort_by(input, &String.length/1)},
    checks: [
      {~S{["ccc", "a", "bb"]}, ~S{["a", "bb", "ccc"]}},
      {~S{["bb", "aa", "c"]}, ~S{["c", "bb", "aa"]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/uniq",
    prompt: ~S{`input` is a list of terms. Return the list with duplicates removed, keeping only the first occurrence of each value, in order.},
    solution: ~S{Enum.uniq(input)},
    checks: [
      {~S{[1, 2, 1, 3, 2]}, ~S{[1, 2, 3]}},
      {~S{[:a, :a, :a]}, ~S{[:a]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/uniq-by-case",
    prompt: ~S{`input` is a list of strings. Return the list with case-insensitive duplicates removed: keep the first occurrence (with its original casing) of each string when compared lowercased, in order.},
    solution: ~S{Enum.uniq_by(input, &String.downcase/1)},
    checks: [
      {~S{["Foo", "FOO", "bar", "BAR"]}, ~S{["Foo", "bar"]}},
      {~S{["a", "b"]}, ~S{["a", "b"]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/dedup",
    prompt: ~S{`input` is a list of terms. Collapse runs of consecutive duplicate elements down to a single element; non-adjacent duplicates must stay. Return the resulting list.},
    solution: ~S{Enum.dedup(input)},
    checks: [
      {~S{[1, 1, 2, 2, 1, 1]}, ~S{[1, 2, 1]}},
      {~S{[1]}, ~S{[1]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/group-by-rem",
    prompt: ~S{`input` is a list of non-negative integers. Return a map grouping the values by their remainder when divided by 3: keys are the remainders (0, 1, or 2), values are lists of the elements with that remainder in original order. Omit keys with no elements.},
    solution: ~S{Enum.group_by(input, &rem(&1, 3))},
    checks: [
      {~S{[1, 2, 3, 4, 5, 6]}, ~S"%{0 => [3, 6], 1 => [1, 4], 2 => [2, 5]}"},
      {~S{[3]}, ~S"%{0 => [3]}"},
      {~S{[]}, ~S"%{}"}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/frequencies",
    prompt: ~S{`input` is a list of strings. Return a map from each distinct string to the number of times it occurs.},
    solution: ~S{Enum.frequencies(input)},
    checks: [
      {~S{["a", "b", "a", "a"]}, ~S(%{"a" => 3, "b" => 1})},
      {~S{["x"]}, ~S(%{"x" => 1})},
      {~S{[]}, ~S"%{}"}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/frequencies-by-length",
    prompt: ~S{`input` is a list of strings. Return a map from string length (an integer) to how many strings in the list have that length.},
    solution: ~S{Enum.frequencies_by(input, &String.length/1)},
    checks: [
      {~S{["a", "bb", "cc", "d"]}, ~S"%{1 => 2, 2 => 2}"},
      {~S{[""]}, ~S"%{0 => 1}"},
      {~S{[]}, ~S"%{}"}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/sliding-windows",
    prompt: ~S{`input` is a list of terms. Return every contiguous window of 3 consecutive elements as a list of lists, advancing one element at a time; windows that would have fewer than 3 elements are discarded entirely.},
    solution: ~S{Enum.chunk_every(input, 3, 1, :discard)},
    checks: [
      {~S{[1, 2, 3, 4]}, ~S{[[1, 2, 3], [2, 3, 4]]}},
      {~S{[1, 2]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/chunk-by-parity",
    prompt: ~S{`input` is a list of integers. Split it into a list of lists, where each inner list is a maximal run of consecutive elements that share the same parity (all even or all odd).},
    solution: ~S{Enum.chunk_by(input, &(rem(&1, 2) == 0))},
    checks: [
      {~S{[1, 3, 2, 4, 5]}, ~S{[[1, 3], [2, 4], [5]]}},
      {~S{[2, 2]}, ~S{[[2, 2]]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/flat-map-twice",
    prompt: ~S{`input` is a list of terms. Return a single flat list where every element of `input` appears twice in a row.},
    solution: ~S{Enum.flat_map(input, &[&1, &1])},
    checks: [
      {~S{[1, 2]}, ~S{[1, 1, 2, 2]}},
      {~S{[:a]}, ~S{[:a, :a]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/map-reduce-running",
    prompt: ~S"`input` is a list of numbers. Return a 2-tuple: the first element is the list of running totals (each position holds the sum of all elements up to and including it), the second is the final total. For an empty list return `{[], 0}`.",
    solution: ~S"Enum.map_reduce(input, 0, fn x, acc -> {x + acc, x + acc} end)",
    checks: [
      {~S{[1, 2, 3]}, ~S"{[1, 3, 6], 6}"},
      {~S{[5]}, ~S"{[5], 5}"},
      {~S{[]}, ~S"{[], 0}"}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/into-map",
    prompt: ~S"`input` is a list of `{key, value}` tuples. Return a map built from those pairs; when a key appears more than once, the later pair wins.",
    solution: ~S"Enum.into(input, %{})",
    checks: [
      {~S"[{:a, 1}, {:b, 2}]", ~S"%{a: 1, b: 2}"},
      {~S"[{:a, 1}, {:a, 9}]", ~S"%{a: 9}"},
      {~S{[]}, ~S"%{}"}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/with-index-one",
    prompt: ~S"`input` is a list of terms. Return a list of `{element, position}` tuples where position starts at 1 for the first element.",
    solution: ~S{Enum.with_index(input, 1)},
    checks: [
      {~S{["a", "b", "c"]}, ~S([{"a", 1}, {"b", 2}, {"c", 3}])},
      {~S{[:x]}, ~S"[{:x, 1}]"},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/zip-with-sum",
    prompt: ~S{`input` is a 2-tuple of lists of numbers. Return a list of the element-wise sums; the result is as long as the shorter list.},
    solution: ~S{Enum.zip_with(elem(input, 0), elem(input, 1), &(&1 + &2))},
    checks: [
      {~S"{[1, 2, 3], [10, 20]}", ~S{[11, 22]}},
      {~S"{[5], [5]}", ~S{[10]}},
      {~S"{[], [1, 2]}", ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/take-last-two",
    prompt: ~S{`input` is a list of terms. Return a list of its last 2 elements in order (the whole list if it has fewer than 2).},
    solution: ~S{Enum.take(input, -2)},
    checks: [
      {~S{[1, 2, 3, 4]}, ~S{[3, 4]}},
      {~S{[1]}, ~S{[1]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/take-while-small",
    prompt: ~S{`input` is a list of integers. Return the leading elements that are less than 5, stopping at the first element that is 5 or greater (later small elements are not included).},
    solution: ~S{Enum.take_while(input, &(&1 < 5))},
    checks: [
      {~S{[1, 4, 7, 2]}, ~S{[1, 4]}},
      {~S{[9, 1]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/take-every-third",
    prompt: ~S{`input` is a list of terms. Return a list of every 3rd element, starting with the first element (i.e. indexes 0, 3, 6, ...).},
    solution: ~S{Enum.take_every(input, 3)},
    checks: [
      {~S{[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]}, ~S{[1, 4, 7, 10]}},
      {~S{[1, 2]}, ~S{[1]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/drop-leading-zeros",
    prompt: ~S{`input` is a list of integers. Remove elements from the front while they are 0, stopping at the first nonzero element; zeros after that stay. Return the resulting list.},
    solution: ~S{Enum.drop_while(input, &(&1 == 0))},
    checks: [
      {~S{[0, 0, 3, 0]}, ~S{[3, 0]}},
      {~S{[1, 2]}, ~S{[1, 2]}},
      {~S{[0]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/split-at-two",
    prompt: ~S"`input` is a list of terms. Return a 2-tuple `{first, rest}` where `first` is a list of the first 2 elements (or all of them if fewer) and `rest` is a list of everything after.",
    solution: ~S{Enum.split(input, 2)},
    checks: [
      {~S{[1, 2, 3, 4]}, ~S"{[1, 2], [3, 4]}"},
      {~S{[1]}, ~S"{[1], []}"},
      {~S{[]}, ~S"{[], []}"}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/split-evens-odds",
    prompt: ~S"`input` is a list of integers. Return a 2-tuple of lists `{evens, odds}` where each side preserves the original order of its elements. A single pass over the list should suffice.",
    solution: ~S{Enum.split_with(input, &(rem(&1, 2) == 0))},
    checks: [
      {~S{[1, 2, 3, 4]}, ~S"{[2, 4], [1, 3]}"},
      {~S{[1, 3]}, ~S"{[], [1, 3]}"},
      {~S{[]}, ~S"{[], []}"}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/at-second-last",
    prompt: ~S{`input` is a list of terms. Return its second-to-last element; if the list has fewer than 2 elements, return the atom `:none`.},
    solution: ~S{Enum.at(input, -2, :none)},
    checks: [
      {~S{[1, 2, 3]}, ~S{2}},
      {~S{[7]}, ~S{:none}},
      {~S{[]}, ~S{:none}}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/fetch-second",
    prompt: ~S"`input` is a list of terms. Return `{:ok, element}` for the element at index 1 (the second element), or the bare atom `:error` if the list is too short.",
    solution: ~S{Enum.fetch(input, 1)},
    checks: [
      {~S{[10, 20, 30]}, ~S"{:ok, 20}"},
      {~S{[10]}, ~S{:error}},
      {~S{[]}, ~S{:error}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/find-even-or-zero",
    prompt: ~S{`input` is a list of integers. Return the first even number in it; if there is none, return 0.},
    solution: ~S{Enum.find(input, 0, &(rem(&1, 2) == 0))},
    checks: [
      {~S{[1, 3, 4, 6]}, ~S{4}},
      {~S{[1, 3, 5]}, ~S{0}},
      {~S{[]}, ~S{0}}
    ],
    tags: [:enum],
    difficulty: :medium
  },
  %{
    id: "enum/find-value-id",
    prompt: ~S{`input` is a list of maps. Return the value stored under the key `:id` in the first map that contains that key (assume stored ids are never `nil` or `false`); return `nil` if no map has the key.},
    solution: ~S{Enum.find_value(input, &Map.get(&1, :id))},
    checks: [
      {~S([%{name: "a"}, %{id: 7}, %{id: 9}]), ~S{7}},
      {~S"[%{}]", ~S{nil}},
      {~S{[]}, ~S{nil}}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/all-positive",
    prompt: ~S{`input` is a list of integers. Return `true` if every element is strictly greater than 0, and `false` otherwise. An empty list must yield `true`.},
    solution: ~S{Enum.all?(input, &(&1 > 0))},
    checks: [
      {~S{[1, 2, 3]}, ~S{true}},
      {~S{[1, 0]}, ~S{false}},
      {~S{[]}, ~S{true}}
    ],
    tags: [:enum],
    difficulty: :hard
  },
  %{
    id: "enum/map-join-upcase",
    prompt: ~S{`input` is a list of lowercase strings. Return one string with every element uppercased, joined by ", " (comma and space). An empty list yields the empty string.},
    solution: ~S{Enum.map_join(input, ", ", &String.upcase/1)},
    checks: [
      {~S{["a", "b"]}, ~S{"A, B"}},
      {~S{["hé"]}, ~S{"HÉ"}},
      {~S{[]}, ~S{""}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/slice-middle",
    prompt: ~S{`input` is a list of terms. Return the elements at indexes 1 through 3 inclusive (fewer if the list ends earlier), as a list.},
    solution: ~S{Enum.slice(input, 1..3)},
    checks: [
      {~S{[1, 2, 3, 4, 5]}, ~S{[2, 3, 4]}},
      {~S{[1, 2]}, ~S{[2]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum],
    difficulty: :easy
  },
  %{
    id: "enum/sum-by-price",
    prompt: ~S{`input` is a list of maps, each with an integer under the key `:price`. Return the total of all prices (0 for an empty list).},
    solution: ~S{Enum.sum_by(input, & &1.price)},
    checks: [
      {~S"[%{price: 10}, %{price: 5}]", ~S{15}},
      {~S"[%{price: -3}]", ~S{-3}},
      {~S{[]}, ~S{0}}
    ],
    tags: [:enum, :drift],
    difficulty: :medium
  },
  %{
    id: "enum/product-by-n",
    prompt: ~S{`input` is a list of maps, each with an integer under the key `:n`. Return the product of all the `:n` values; an empty list yields 1.},
    solution: ~S{Enum.product_by(input, & &1.n)},
    checks: [
      {~S"[%{n: 2}, %{n: 3}, %{n: 4}]", ~S{24}},
      {~S"[%{n: 7}]", ~S{7}},
      {~S{[]}, ~S{1}}
    ],
    tags: [:enum, :drift],
    difficulty: :medium
  },

  # ── Enum: traps (nonexistent-function temptations) ───────────────────────
  %{
    id: "enum/drop-nils",
    prompt: ~S{`input` is a list of terms. Return the list with all `nil` values removed. Other falsy values like `false` must be kept.},
    solution: ~S{Enum.reject(input, &is_nil/1)},
    checks: [
      {~S{[1, nil, false, 2]}, ~S{[1, false, 2]}},
      {~S{[nil, nil]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum, :trap],
    difficulty: :easy
  },
  %{
    id: "enum/average",
    prompt: ~S{`input` is a nonempty list of integers. Return the arithmetic mean of the elements as a float.},
    solution: ~S{Enum.sum(input) / length(input)},
    checks: [
      {~S{[1, 2, 3]}, ~S{2.0}},
      {~S{[1, 2]}, ~S{1.5}},
      {~S{[7]}, ~S{7.0}}
    ],
    tags: [:enum, :trap],
    difficulty: :medium
  },
  %{
    id: "enum/none-negative",
    prompt: ~S{`input` is a list of integers. Return `true` if no element is negative, `false` if at least one is. An empty list yields `true`.},
    solution: ~S{not Enum.any?(input, &(&1 < 0))},
    checks: [
      {~S{[1, 0, 2]}, ~S{true}},
      {~S{[1, -1]}, ~S{false}},
      {~S{[]}, ~S{true}}
    ],
    tags: [:enum, :trap],
    difficulty: :easy
  },
  %{
    id: "enum/index-of",
    prompt: ~S{`input` is a list of terms. Return the 0-based index of the first occurrence of the integer 3, or `nil` if 3 does not occur.},
    solution: ~S{Enum.find_index(input, &(&1 == 3))},
    checks: [
      {~S{[5, 3, 9, 3]}, ~S{1}},
      {~S{[1, 2]}, ~S{nil}},
      {~S{[]}, ~S{nil}}
    ],
    tags: [:enum, :trap],
    difficulty: :medium
  },
  %{
    id: "enum/flatten-once",
    prompt: ~S{`input` is a list of lists. Concatenate them into one list, flattening exactly one level: lists nested inside the inner lists must remain lists.},
    solution: ~S{Enum.concat(input)},
    checks: [
      {~S{[[1, [2]], [3]]}, ~S{[1, [2], 3]}},
      {~S{[[], [1]]}, ~S{[1]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum, :trap],
    difficulty: :hard
  },
  %{
    id: "enum/drop-last",
    prompt: ~S{`input` is a list of terms. Return the list without its final element; an empty list stays empty.},
    solution: ~S{Enum.drop(input, -1)},
    checks: [
      {~S{[1, 2, 3]}, ~S{[1, 2]}},
      {~S{[1]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:enum, :trap],
    difficulty: :medium
  },

  # ── Stream: laziness ──────────────────────────────────────────────────────
  %{
    id: "enum/stream-first-squares",
    prompt: ~S{`input` is an enumerable of integers that may be infinite (e.g. a Stream). Return a list of the squares of its first 5 elements (fewer if it yields fewer than 5). Your expression must terminate even on infinite input.},
    solution: ~S{input |> Stream.map(&(&1 * &1)) |> Enum.take(5)},
    checks: [
      {~S{Stream.iterate(1, &(&1 + 1))}, ~S{[1, 4, 9, 16, 25]}},
      {~S{[1, 2, 3]}, ~S{[1, 4, 9]}}
    ],
    tags: [:stream, :enum],
    difficulty: :medium
  },
  %{
    id: "enum/stream-first-evens",
    prompt: ~S{`input` is an enumerable of positive integers that may be infinite but is guaranteed to contain infinitely many even numbers if infinite. Return a list of the first 4 even numbers it yields (fewer if it runs out). Must terminate on infinite input.},
    solution: ~S{input |> Stream.filter(&(rem(&1, 2) == 0)) |> Enum.take(4)},
    checks: [
      {~S{Stream.iterate(1, &(&1 + 1))}, ~S{[2, 4, 6, 8]}},
      {~S{[1, 2, 3, 4]}, ~S{[2, 4]}},
      {~S{[1, 3]}, ~S{[]}}
    ],
    tags: [:stream, :enum],
    difficulty: :medium
  },
  %{
    id: "enum/stream-doubling",
    prompt: ~S{`input` is a positive integer. Return a list of the first 6 terms of the sequence that starts at `input` and doubles at each step.},
    solution: ~S{Stream.iterate(input, &(&1 * 2)) |> Enum.take(6)},
    checks: [
      {~S{1}, ~S{[1, 2, 4, 8, 16, 32]}},
      {~S{3}, ~S{[3, 6, 12, 24, 48, 96]}}
    ],
    tags: [:stream],
    difficulty: :easy
  },
  %{
    id: "enum/stream-cycle-seven",
    prompt: ~S{`input` is a nonempty list. Return a list of the first 7 elements produced by repeating `input` over and over endlessly.},
    solution: ~S{input |> Stream.cycle() |> Enum.take(7)},
    checks: [
      {~S{[1, 2, 3]}, ~S{[1, 2, 3, 1, 2, 3, 1]}},
      {~S{[:a]}, ~S{[:a, :a, :a, :a, :a, :a, :a]}}
    ],
    tags: [:stream],
    difficulty: :easy
  },
  %{
    id: "enum/stream-unfold-digits",
    prompt: ~S{`input` is a positive integer. Return the list of its base-10 digits in least-significant-first order (e.g. the digits of 105 are 5, then 0, then 1).},
    solution: ~S"Stream.unfold(input, fn 0 -> nil; n -> {rem(n, 10), div(n, 10)} end) |> Enum.to_list()",
    checks: [
      {~S{105}, ~S{[5, 0, 1]}},
      {~S{7}, ~S{[7]}},
      {~S{123}, ~S{[3, 2, 1]}}
    ],
    tags: [:stream],
    difficulty: :hard
  },
  %{
    id: "enum/stream-chunk-pairs",
    prompt: ~S{`input` is an enumerable of terms that may be infinite. Return a list of the first 3 chunks when the elements are grouped into consecutive pairs (a trailing chunk may be shorter on finite input). Must terminate on infinite input.},
    solution: ~S{input |> Stream.chunk_every(2) |> Enum.take(3)},
    checks: [
      {~S{Stream.iterate(1, &(&1 + 1))}, ~S{[[1, 2], [3, 4], [5, 6]]}},
      {~S{[1, 2, 3]}, ~S{[[1, 2], [3]]}}
    ],
    tags: [:stream, :enum],
    difficulty: :medium
  },
  %{
    id: "enum/stream-with-index",
    prompt: ~S"`input` is an enumerable of terms that may be infinite. Return a list of the first 4 `{element, index}` tuples, with indexes starting at 0. Must terminate on infinite input.",
    solution: ~S{input |> Stream.with_index() |> Enum.take(4)},
    checks: [
      {~S{Stream.cycle([:a, :b])}, ~S"[{:a, 0}, {:b, 1}, {:a, 2}, {:b, 3}]"},
      {~S{["x"]}, ~S([{"x", 0}])}
    ],
    tags: [:stream, :enum],
    difficulty: :medium
  },
  %{
    id: "enum/stream-dedup-first-three",
    prompt: ~S{`input` is an enumerable of terms that may be infinite. Collapse runs of consecutive duplicates to a single value, then return a list of the first 3 resulting values (fewer if finite input yields fewer). Must terminate on infinite input.},
    solution: ~S{input |> Stream.dedup() |> Enum.take(3)},
    checks: [
      {~S{Stream.cycle([1, 1, 2, 2, 3, 3])}, ~S{[1, 2, 3]}},
      {~S{[5, 5, 5]}, ~S{[5]}},
      {~S{[1, 1, 2, 1, 1]}, ~S{[1, 2, 1]}}
    ],
    tags: [:stream, :enum],
    difficulty: :hard
  },
  %{
    id: "enum/stream-take-while-small",
    prompt: ~S{`input` is an enumerable of strictly increasing integers that may be infinite. Return a list of the leading elements that are less than 10, stopping at the first element that is 10 or more. Must terminate on infinite input.},
    solution: ~S{Enum.take_while(input, &(&1 < 10))},
    checks: [
      {~S{Stream.iterate(1, &(&1 + 1))}, ~S{[1, 2, 3, 4, 5, 6, 7, 8, 9]}},
      {~S{[12]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:stream, :enum],
    difficulty: :easy
  },
  %{
    id: "enum/stream-budget",
    prompt: ~S{`input` is an enumerable of positive integers that may be infinite. Collect elements from the front one by one as long as the running total stays at most 10; stop before the element that would push the total above 10. Return the collected elements as a list. Must terminate on infinite input.},
    solution: ~S"input |> Stream.transform(0, fn x, acc -> if acc + x > 10, do: {:halt, acc}, else: {[x], acc + x} end) |> Enum.to_list()",
    checks: [
      {~S{Stream.iterate(1, &(&1 + 1))}, ~S{[1, 2, 3, 4]}},
      {~S{[5, 5, 5]}, ~S{[5, 5]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:stream, :enum],
    difficulty: :hard
  },
  %{
    id: "enum/stream-even-squares",
    prompt: ~S{`input` is an enumerable of positive integers that may be infinite but contains infinitely many even numbers if infinite. Return a list of the squares of the first 3 even numbers it yields (fewer if it runs out). Must terminate on infinite input.},
    solution: ~S{input |> Stream.filter(&(rem(&1, 2) == 0)) |> Stream.map(&(&1 * &1)) |> Enum.take(3)},
    checks: [
      {~S{Stream.iterate(1, &(&1 + 1))}, ~S{[4, 16, 36]}},
      {~S{[1, 2, 3]}, ~S{[4]}}
    ],
    tags: [:stream, :enum],
    difficulty: :medium
  },

  # ── Capture syntax / Function ─────────────────────────────────────────────
  %{
    id: "enum/capture-abs",
    prompt: ~S{`input` is a list of integers. Return a list of their absolute values, in order.},
    solution: ~S{Enum.map(input, &abs/1)},
    checks: [
      {~S{[-1, 2, -3]}, ~S{[1, 2, 3]}},
      {~S{[0]}, ~S{[0]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:capture, :enum],
    difficulty: :easy
  },
  %{
    id: "enum/capture-scan-sums",
    prompt: ~S{`input` is a list of numbers. Return the list of prefix sums: element i of the result is the sum of the first i+1 elements of `input`.},
    solution: ~S{Enum.scan(input, &(&1 + &2))},
    checks: [
      {~S{[1, 2, 3]}, ~S{[1, 3, 6]}},
      {~S{[5]}, ~S{[5]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:capture, :enum],
    difficulty: :medium
  },
  %{
    id: "enum/capture-reverse-each",
    prompt: ~S{`input` is a list of lists. Return a list where each inner list is reversed; the outer order is unchanged.},
    solution: ~S{Enum.map(input, &Enum.reverse/1)},
    checks: [
      {~S{[[1, 2], [3]]}, ~S{[[2, 1], [3]]}},
      {~S{[[]]}, ~S{[[]]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:capture, :enum],
    difficulty: :easy
  },
  %{
    id: "enum/function-identity-truthy",
    prompt: ~S{`input` is a list of terms. Return the list with all falsy values (`nil` and `false`) removed, preserving order.},
    solution: ~S{Enum.filter(input, &Function.identity/1)},
    checks: [
      {~S{[1, nil, false, :a]}, ~S{[1, :a]}},
      {~S{[false]}, ~S{[]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:function, :enum],
    difficulty: :medium
  },
  %{
    id: "enum/apply-mfa",
    prompt: ~S"`input` is a 3-tuple `{module, function_name, args}` where module and function_name are atoms and args is a list. Dynamically invoke that function with those arguments and return its result.",
    solution: ~S{apply(elem(input, 0), elem(input, 1), elem(input, 2))},
    checks: [
      {~S"{Enum, :member?, [[1, 2, 3], 2]}", ~S{true}},
      {~S({String, :upcase, ["héllo"]}), ~S{"HÉLLO"}},
      {~S"{Kernel, :max, [3, 9]}", ~S{9}}
    ],
    tags: [:function],
    difficulty: :medium
  },
  %{
    id: "enum/then-wrap",
    prompt: ~S{`input` is a list of strings. Return a single string: the elements joined by ", " (comma and space), with the whole thing wrapped in square brackets. An empty list yields "[]".},
    solution: ~S{input |> Enum.join(", ") |> then(&("[" <> &1 <> "]"))},
    checks: [
      {~S{["a", "b"]}, ~S{"[a, b]"}},
      {~S{["x"]}, ~S{"[x]"}},
      {~S{[]}, ~S{"[]"}}
    ],
    tags: [:function, :enum],
    difficulty: :easy
  },
  %{
    id: "enum/tap-passthrough",
    prompt: ~S{`input` is a list of numbers. Return the value that the pipeline `input |> tap(&Enum.sum/1)` evaluates to (i.e. demonstrate what `tap/2` returns).},
    solution: ~S{input |> tap(&Enum.sum/1)},
    checks: [
      {~S{[1, 2]}, ~S{[1, 2]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:function],
    difficulty: :easy
  }
]
