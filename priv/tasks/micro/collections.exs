# Micro items: Map, Keyword, List, MapSet, Tuple.
[
  # ── Map ────────────────────────────────────────────────────────────────
  %{
    id: "collections/map-get-default",
    prompt: ~S{`input` is a map with atom keys. Return the value stored under :port, or 8080 when that key is absent.},
    solution: ~S{Map.get(input, :port, 8080)},
    checks: [
      {~S|%{port: 4000, host: "h"}|, ~S|4000|},
      {~S|%{host: "h"}|, ~S|8080|},
      {~S|%{}|, ~S|8080|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-value-or-nil",
    prompt: ~S{`input` is a map with atom keys. Return the value stored under :city, or nil when the key is absent — the expression must not raise for a missing key.},
    solution: ~S{input[:city]},
    checks: [
      {~S|%{city: "Oslo", pop: 700_000}|, ~S|"Oslo"|},
      {~S|%{}|, ~S|nil|}
    ],
    tags: [:map, :gotcha],
    difficulty: :easy
  },
  %{
    id: "collections/map-string-keys",
    prompt: ~S{`input` is a map whose keys are strings. Return the value stored under the key "name", or nil when it is absent.},
    solution: ~S{input["name"]},
    checks: [
      {~S|%{"name" => "Ada", "age" => 36}|, ~S|"Ada"|},
      {~S|%{"age" => 1}|, ~S|nil|}
    ],
    tags: [:map, :gotcha],
    difficulty: :easy
  },
  %{
    id: "collections/map-entry-count",
    prompt: ~S{`input` is a map. Return the number of key-value pairs it holds, as an integer.},
    solution: ~S{map_size(input)},
    checks: [
      {~S|%{}|, ~S|0|},
      {~S|%{a: 1, b: 2}|, ~S|2|}
    ],
    tags: [:map, :gotcha],
    difficulty: :easy
  },
  %{
    id: "collections/map-has-key",
    prompt: ~S{`input` is a map. Return true when it contains the atom key :id, false otherwise.},
    solution: ~S{Map.has_key?(input, :id)},
    checks: [
      {~S|%{id: 1, name: "x"}|, ~S|true|},
      {~S|%{}|, ~S|false|},
      {~S|%{"id" => 1}|, ~S|false|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-put",
    prompt: ~S{`input` is a map. Return it with the key :status set to :ok, overwriting any existing value.},
    solution: ~S{Map.put(input, :status, :ok)},
    checks: [
      {~S|%{}|, ~S|%{status: :ok}|},
      {~S|%{status: :old, x: 1}|, ~S|%{status: :ok, x: 1}|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-delete",
    prompt: ~S{`input` is a map. Return it without the key :password; when the key is absent, return the map unchanged.},
    solution: ~S{Map.delete(input, :password)},
    checks: [
      {~S|%{password: "s3cret", user: "u"}|, ~S|%{user: "u"}|},
      {~S|%{user: "u"}|, ~S|%{user: "u"}|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-drop",
    prompt: ~S{`input` is a map. Return it without the keys :a and :b (absent keys are simply ignored).},
    solution: ~S{Map.drop(input, [:a, :b])},
    checks: [
      {~S|%{a: 1, b: 2, c: 3}|, ~S|%{c: 3}|},
      {~S|%{c: 3}|, ~S|%{c: 3}|},
      {~S|%{}|, ~S|%{}|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-take",
    prompt: ~S{`input` is a map. Return a map containing only the entries for the keys :name and :age (keys absent from input are ignored).},
    solution: ~S{Map.take(input, [:name, :age])},
    checks: [
      {~S|%{name: "A", age: 3, x: 1}|, ~S|%{name: "A", age: 3}|},
      {~S|%{name: "A"}|, ~S|%{name: "A"}|},
      {~S|%{}|, ~S|%{}|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-keys-sorted",
    prompt: ~S{`input` is a map with atom keys. Return the list of its keys sorted in ascending order.},
    solution: ~S{Enum.sort(Map.keys(input))},
    checks: [
      {~S|%{b: 1, a: 2, c: 3}|, ~S|[:a, :b, :c]|},
      {~S|%{}|, ~S|[]|}
    ],
    tags: [:map],
    difficulty: :easy
  },
  %{
    id: "collections/map-fetch",
    prompt: ~S|`input` is a map. Return {:ok, value} for the key :a, or the atom :error when :a is absent.|,
    solution: ~S{Map.fetch(input, :a)},
    checks: [
      {~S|%{a: 1, b: 2}|, ~S|{:ok, 1}|},
      {~S|%{b: 2}|, ~S|:error|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-fetch-raise",
    prompt: ~S{`input` is a map. Return the value stored under :name; the expression must raise KeyError when :name is absent.},
    solution: ~S{Map.fetch!(input, :name)},
    checks: [
      {~S|%{name: "Ada"}|, ~S|"Ada"|}
    ],
    raw_checks: [
      ~S|assert_raise KeyError, fn -> Micro.solve(%{}) end|
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-put-new",
    prompt: ~S{`input` is a map. Return it with :retries set to 3 only when :retries is absent; an existing value must be kept untouched.},
    solution: ~S{Map.put_new(input, :retries, 3)},
    checks: [
      {~S|%{}|, ~S|%{retries: 3}|},
      {~S|%{retries: 7}|, ~S|%{retries: 7}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-merge-sum",
    prompt: ~S|`input` is a map. Merge the map %{bonus: 10} into it: all entries of input are kept, and when input already contains :bonus the result's :bonus must be the sum of input's value and 10.|,
    solution: ~S|Map.merge(input, %{bonus: 10}, fn _k, a, b -> a + b end)|,
    checks: [
      {~S|%{bonus: 5, x: 1}|, ~S|%{bonus: 15, x: 1}|},
      {~S|%{x: 1}|, ~S|%{x: 1, bonus: 10}|},
      {~S|%{}|, ~S|%{bonus: 10}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-update-or-init",
    prompt: ~S{`input` is a map. Return it with :count incremented by 1; when :count is absent, set it to 1.},
    solution: ~S{Map.update(input, :count, 1, &(&1 + 1))},
    checks: [
      {~S|%{count: 2}|, ~S|%{count: 3}|},
      {~S|%{}|, ~S|%{count: 1}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-pop",
    prompt: ~S|`input` is a map. Return the 2-tuple {value, rest} where value is the entry under :token (nil when absent) and rest is input without the :token key.|,
    solution: ~S{Map.pop(input, :token)},
    checks: [
      {~S|%{token: "t", a: 1}|, ~S|{"t", %{a: 1}}|},
      {~S|%{a: 1}|, ~S|{nil, %{a: 1}}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-new-transform",
    prompt: ~S{`input` is a list of strings. Return a map where each string maps to its length in graphemes (String.length).},
    solution: ~S|Map.new(input, fn s -> {s, String.length(s)} end)|,
    checks: [
      {~S|["ab", "c"]|, ~S|%{"ab" => 2, "c" => 1}|},
      {~S|[]|, ~S|%{}|},
      {~S|["é"]|, ~S|%{"é" => 1}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-from-keys",
    prompt: ~S{`input` is a list of atoms (no duplicates). Return a map where every atom from input is a key with the value 0.},
    solution: ~S{Map.from_keys(input, 0)},
    checks: [
      {~S|[:a, :b]|, ~S|%{a: 0, b: 0}|},
      {~S|[]|, ~S|%{}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-from-struct",
    prompt: ~S{`input` is a Date struct such as ~D[2024-01-15]. Return a plain map of its fields (:year, :month, :day, :calendar) without the :__struct__ key.},
    solution: ~S{Map.from_struct(input)},
    checks: [
      {~S|~D[2024-01-15]|, ~S|%{calendar: Calendar.ISO, year: 2024, month: 1, day: 15}|},
      {~S|~D[0001-01-01]|, ~S|%{calendar: Calendar.ISO, year: 1, month: 1, day: 1}|}
    ],
    tags: [:map],
    difficulty: :medium
  },
  %{
    id: "collections/map-update-existing",
    prompt: ~S{`input` is a map. Return it with the value under :count replaced by its current value plus 1. The expression must raise KeyError when :count is absent.},
    solution: ~S[%{input | count: input.count + 1}],
    checks: [
      {~S|%{count: 1, x: :y}|, ~S|%{count: 2, x: :y}|}
    ],
    raw_checks: [
      ~S|assert_raise KeyError, fn -> Micro.solve(%{other: 1}) end|
    ],
    tags: [:map, :gotcha],
    difficulty: :hard
  },
  %{
    id: "collections/map-empty-or-not",
    prompt: ~S{`input` is a map. Return the atom :empty when it has no entries, and :nonempty otherwise.},
    solution: ~S{if map_size(input) == 0, do: :empty, else: :nonempty},
    checks: [
      {~S|%{}|, ~S|:empty|},
      {~S|%{a: 1}|, ~S|:nonempty|},
      {~S|%{"x" => 1, "y" => 2}|, ~S|:nonempty|}
    ],
    tags: [:map, :gotcha],
    difficulty: :hard
  },
  %{
    id: "collections/map-get-and-update",
    prompt: ~S|`input` is a map. Return the 2-tuple {previous, updated}: previous is the current value under :n (nil when absent) and updated is input with :n set to that value plus 1, treating a missing value as 0.|,
    solution: ~S[Map.get_and_update(input, :n, fn v -> {v, (v || 0) + 1} end)],
    checks: [
      {~S|%{n: 5}|, ~S|{5, %{n: 6}}|},
      {~S|%{}|, ~S|{nil, %{n: 1}}|}
    ],
    tags: [:map],
    difficulty: :hard
  },

  # ── Keyword ────────────────────────────────────────────────────────────
  %{
    id: "collections/keyword-first-value",
    prompt: ~S{`input` is a keyword list that may contain the key :a more than once. Return the value of the first :a entry, or nil when :a is absent.},
    solution: ~S{Keyword.get(input, :a)},
    checks: [
      {~S|[a: 1, b: 2, a: 3]|, ~S|1|},
      {~S|[b: 2]|, ~S|nil|},
      {~S|[]|, ~S|nil|}
    ],
    tags: [:keyword, :gotcha],
    difficulty: :hard
  },
  %{
    id: "collections/keyword-all-values",
    prompt: ~S{`input` is a keyword list that may contain the key :a more than once. Return the list of ALL values stored under :a, in their original order.},
    solution: ~S{Keyword.get_values(input, :a)},
    checks: [
      {~S|[a: 1, b: 5, a: 2]|, ~S|[1, 2]|},
      {~S|[b: 1]|, ~S|[]|}
    ],
    tags: [:keyword],
    difficulty: :medium
  },
  %{
    id: "collections/keyword-put",
    prompt: ~S|`input` is a keyword list that may contain duplicate keys. Return it with :a set to 0: every existing :a entry is removed and the new pair {:a, 0} becomes the FIRST element; the other pairs keep their relative order.|,
    solution: ~S{Keyword.put(input, :a, 0)},
    checks: [
      {~S|[b: 1, a: 2, c: 3, a: 4]|, ~S|[a: 0, b: 1, c: 3]|},
      {~S|[]|, ~S|[a: 0]|}
    ],
    tags: [:keyword],
    difficulty: :hard
  },
  %{
    id: "collections/keyword-delete-all",
    prompt: ~S{`input` is a keyword list that may contain duplicate keys. Return it with EVERY :a entry removed; the other pairs keep their order.},
    solution: ~S{Keyword.delete(input, :a)},
    checks: [
      {~S|[a: 1, b: 2, a: 3]|, ~S|[b: 2]|},
      {~S|[b: 2]|, ~S|[b: 2]|}
    ],
    tags: [:keyword],
    difficulty: :medium
  },
  %{
    id: "collections/keyword-merge",
    prompt: ~S|`input` is a 2-tuple {left, right} of keyword lists, each without duplicate keys. Merge right into left: the result is the left entries whose keys do NOT appear in right (in their original order), followed by all entries of right (in their original order).|,
    solution: ~S{Keyword.merge(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{[a: 1, b: 2], [b: 9, c: 3]}|, ~S|[a: 1, b: 9, c: 3]|},
      {~S|{[b: 2, a: 1], [b: 9, c: 3]}|, ~S|[a: 1, b: 9, c: 3]|},
      {~S|{[], [x: 1]}|, ~S|[x: 1]|}
    ],
    tags: [:keyword],
    difficulty: :medium
  },
  %{
    id: "collections/keyword-has-key",
    prompt: ~S{`input` is a keyword list. Return true when it contains the key :debug, false otherwise.},
    solution: ~S{Keyword.has_key?(input, :debug)},
    checks: [
      {~S|[debug: true, verbose: false]|, ~S|true|},
      {~S|[]|, ~S|false|}
    ],
    tags: [:keyword],
    difficulty: :easy
  },
  %{
    id: "collections/keyword-keys-dup",
    prompt: ~S{`input` is a keyword list that may contain duplicate keys. Return the list of its keys in order, INCLUDING duplicates.},
    solution: ~S{Keyword.keys(input)},
    checks: [
      {~S|[a: 1, b: 2, a: 3]|, ~S|[:a, :b, :a]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:keyword],
    difficulty: :hard
  },
  %{
    id: "collections/keyword-fetch",
    prompt: ~S|`input` is a keyword list. Return {:ok, value} for the key :a, or the atom :error when :a is absent.|,
    solution: ~S{Keyword.fetch(input, :a)},
    checks: [
      {~S|[a: 1, b: 2]|, ~S|{:ok, 1}|},
      {~S|[b: 2]|, ~S|:error|}
    ],
    tags: [:keyword],
    difficulty: :medium
  },
  %{
    id: "collections/keyword-pop",
    prompt: ~S|`input` is a keyword list that may contain duplicate keys. Return the 2-tuple {value, rest} where value is the FIRST value under :a (nil when absent) and rest is input with EVERY :a entry removed.|,
    solution: ~S{Keyword.pop(input, :a)},
    checks: [
      {~S|[a: 1, b: 2, a: 3]|, ~S|{1, [b: 2]}|},
      {~S|[b: 2]|, ~S|{nil, [b: 2]}|}
    ],
    tags: [:keyword],
    difficulty: :hard
  },
  %{
    id: "collections/keyword-check",
    prompt: ~S{`input` is an arbitrary term. Return true when it is a keyword list — a list of 2-tuples whose first elements are all atoms; the empty list qualifies. Return false otherwise.},
    solution: ~S{Keyword.keyword?(input)},
    checks: [
      {~S|[a: 1, b: 2]|, ~S|true|},
      {~S|[{"a", 1}]|, ~S|false|},
      {~S|[]|, ~S|true|}
    ],
    tags: [:keyword],
    difficulty: :easy
  },
  %{
    id: "collections/keyword-validate",
    prompt: ~S|`input` is an options keyword list. The only allowed keys are :name and :size, where :size defaults to 10 and :name has no default (it only appears in the result when given). Return {:ok, opts} with opts sorted by key and defaults applied, or {:error, invalid} where invalid is the list of unknown keys.|,
    solution: ~S|with {:ok, opts} <- Keyword.validate(input, [:name, size: 10]), do: {:ok, Enum.sort(opts)}|,
    checks: [
      {~S|[name: "a"]|, ~S|{:ok, [name: "a", size: 10]}|},
      {~S|[size: 1, bogus: 2]|, ~S|{:error, [:bogus]}|},
      {~S|[]|, ~S|{:ok, [size: 10]}|}
    ],
    tags: [:keyword, :drift],
    difficulty: :hard
  },
  %{
    id: "collections/keyword-into-map",
    prompt: ~S{`input` is a keyword list without duplicate keys. Return an equivalent map with the same keys and values.},
    solution: ~S{Map.new(input)},
    checks: [
      {~S|[a: 1, b: 2]|, ~S|%{a: 1, b: 2}|},
      {~S|[]|, ~S|%{}|}
    ],
    tags: [:keyword, :trap],
    difficulty: :easy
  },

  # ── List ───────────────────────────────────────────────────────────────
  %{
    id: "collections/list-first-or-default",
    prompt: ~S{`input` is a list of integers. Return its first element, or 0 when the list is empty.},
    solution: ~S{List.first(input, 0)},
    checks: [
      {~S|[5, 6]|, ~S|5|},
      {~S|[]|, ~S|0|}
    ],
    tags: [:list],
    difficulty: :easy
  },
  %{
    id: "collections/list-flatten",
    prompt: ~S{`input` is a list that may contain arbitrarily nested lists. Return a flat list of all non-list elements in order.},
    solution: ~S{List.flatten(input)},
    checks: [
      {~S|[1, [2, [3, []]], 4]|, ~S|[1, 2, 3, 4]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:list],
    difficulty: :easy
  },
  %{
    id: "collections/list-wrap",
    prompt: ~S{`input` is an arbitrary term. Return it as a list: when input is already a list return it unchanged, when input is nil return the empty list, otherwise return a one-element list containing input.},
    solution: ~S{List.wrap(input)},
    checks: [
      {~S|1|, ~S|[1]|},
      {~S|nil|, ~S|[]|},
      {~S|[1, 2]|, ~S|[1, 2]|}
    ],
    tags: [:list],
    difficulty: :medium
  },
  %{
    id: "collections/list-insert-clamped",
    prompt: ~S{`input` is a list. Return it with the atom :x inserted at index 2 (zero-based); when the list has fewer than 2 elements, :x must end up as the last element.},
    solution: ~S{List.insert_at(input, 2, :x)},
    checks: [
      {~S|[1, 2, 3]|, ~S|[1, 2, :x, 3]|},
      {~S|[1]|, ~S|[1, :x]|},
      {~S|[]|, ~S|[:x]|}
    ],
    tags: [:list],
    difficulty: :hard
  },
  %{
    id: "collections/list-update-at",
    prompt: ~S{`input` is a list of integers. Return it with the element at index 1 (zero-based) multiplied by 10; when there is no index 1, return the list unchanged.},
    solution: ~S{List.update_at(input, 1, &(&1 * 10))},
    checks: [
      {~S|[1, 2, 3]|, ~S|[1, 20, 3]|},
      {~S|[7]|, ~S|[7]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:list],
    difficulty: :medium
  },
  %{
    id: "collections/list-delete-first-occurrence",
    prompt: ~S{`input` is a list of integers. Return it with only the FIRST occurrence of the value 2 removed; later occurrences stay. When 2 is absent, return the list unchanged.},
    solution: ~S{List.delete(input, 2)},
    checks: [
      {~S|[1, 2, 3, 2]|, ~S|[1, 3, 2]|},
      {~S|[1, 3]|, ~S|[1, 3]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:list],
    difficulty: :medium
  },
  %{
    id: "collections/list-zip",
    prompt: ~S{`input` is a list of lists. Return a list of tuples where the i-th tuple contains the i-th element of every inner list, truncated to the length of the shortest inner list. For an empty input return the empty list.},
    solution: ~S{Enum.zip(input)},
    checks: [
      {~S|[[1, 2, 3], [:a, :b]]|, ~S|[{1, :a}, {2, :b}]|},
      {~S|[[1, 2], [3, 4]]|, ~S|[{1, 3}, {2, 4}]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:list],
    difficulty: :medium
  },
  %{
    id: "collections/list-keyfind",
    prompt: ~S{`input` is a list of 2-tuples. Return the first tuple whose FIRST element (position 0) is :b, or nil when there is none.},
    solution: ~S{List.keyfind(input, :b, 0)},
    checks: [
      {~S|[{:a, 1}, {:b, 2}, {:b, 3}]|, ~S|{:b, 2}|},
      {~S|[{:a, 1}]|, ~S|nil|}
    ],
    tags: [:list],
    difficulty: :medium
  },
  %{
    id: "collections/list-keyreplace",
    prompt: ~S|`input` is a list of 2-tuples. Return it with the FIRST tuple whose first element (position 0) is :b replaced by the tuple {:b, 0}; later :b tuples stay. When no such tuple exists, return the list unchanged.|,
    solution: ~S|List.keyreplace(input, :b, 0, {:b, 0})|,
    checks: [
      {~S|[{:a, 1}, {:b, 2}, {:b, 3}]|, ~S|[{:a, 1}, {:b, 0}, {:b, 3}]|},
      {~S|[{:a, 1}]|, ~S|[{:a, 1}]|}
    ],
    tags: [:list],
    difficulty: :hard
  },
  %{
    id: "collections/list-starts-with",
    prompt: ~S{`input` is a list. Return true when it starts with the prefix [1, 2] (in that order), false otherwise.},
    solution: ~S{List.starts_with?(input, [1, 2])},
    checks: [
      {~S|[1, 2, 3]|, ~S|true|},
      {~S|[2, 1]|, ~S|false|},
      {~S|[1]|, ~S|false|}
    ],
    tags: [:list],
    difficulty: :easy
  },
  %{
    id: "collections/list-foldr",
    prompt: ~S{`input` is a list of strings. Fold it from the RIGHT with the function fn x, acc -> x <> acc end and the initial accumulator "" — i.e. compute f(x1, f(x2, ... f(xn, ""))). Return the resulting string.},
    solution: ~S{List.foldr(input, "", fn x, acc -> x <> acc end)},
    checks: [
      {~S|["a", "b", "c"]|, ~S|"abc"|},
      {~S|["x"]|, ~S|"x"|},
      {~S|[]|, ~S|""|}
    ],
    tags: [:list],
    difficulty: :hard
  },
  %{
    id: "collections/list-head-strict",
    prompt: ~S{`input` is a list. Return its head (the first element). The expression must raise ArgumentError when input is the empty list.},
    solution: ~S{hd(input)},
    checks: [
      {~S|[1, 2, 3]|, ~S|1|},
      {~S|[:only]|, ~S|:only|}
    ],
    raw_checks: [
      ~S{assert_raise ArgumentError, fn -> Micro.solve([]) end}
    ],
    tags: [:list, :gotcha],
    difficulty: :medium
  },
  %{
    id: "collections/list-subtract-once",
    prompt: ~S{`input` is a list of integers. Return it with one occurrence of 2 and one occurrence of 3 removed — only the FIRST occurrence of each; values that are absent are simply ignored and all other elements keep their order.},
    solution: ~S{input -- [2, 3]},
    checks: [
      {~S|[2, 3, 2, 3]|, ~S|[2, 3]|},
      {~S|[1, 2]|, ~S|[1]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:list, :gotcha],
    difficulty: :hard
  },
  %{
    id: "collections/list-prepend",
    prompt: ~S{`input` is a list. Return it with the integer 0 added as the new FIRST element.},
    solution: ~S{[0 | input]},
    checks: [
      {~S|[1, 2]|, ~S|[0, 1, 2]|},
      {~S|[]|, ~S|[0]|}
    ],
    tags: [:list, :gotcha],
    difficulty: :easy
  },
  %{
    id: "collections/list-membership",
    prompt: ~S{`input` is a list of integers. Return true when it contains the value 3, false otherwise.},
    solution: ~S{3 in input},
    checks: [
      {~S|[1, 3]|, ~S|true|},
      {~S|[2, 4]|, ~S|false|},
      {~S|[]|, ~S|false|}
    ],
    tags: [:list, :trap],
    difficulty: :easy
  },
  %{
    id: "collections/list-reversed",
    prompt: ~S{`input` is a list. Return a list with the same elements in reverse order.},
    solution: ~S{Enum.reverse(input)},
    checks: [
      {~S|[1, 2, 3]|, ~S|[3, 2, 1]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:list, :trap],
    difficulty: :easy
  },
  %{
    id: "collections/list-count",
    prompt: ~S{`input` is a list. Return the number of elements it contains, as an integer.},
    solution: ~S{length(input)},
    checks: [
      {~S|[]|, ~S|0|},
      {~S|[:a, :b]|, ~S|2|}
    ],
    tags: [:list, :trap],
    difficulty: :easy
  },
  %{
    id: "collections/list-append-one",
    prompt: ~S{`input` is a list. Return it with the atom :done added as the new LAST element.},
    solution: ~S{input ++ [:done]},
    checks: [
      {~S|[1, 2]|, ~S|[1, 2, :done]|},
      {~S|[]|, ~S|[:done]|}
    ],
    tags: [:list, :trap],
    difficulty: :medium
  },

  # ── MapSet ─────────────────────────────────────────────────────────────
  %{
    id: "collections/set-distinct-sorted",
    prompt: ~S{`input` is a list of integers. Return the sorted list (ascending) of its distinct values.},
    solution: ~S{input |> MapSet.new() |> Enum.sort()},
    checks: [
      {~S|[3, 1, 3, 2]|, ~S|[1, 2, 3]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:map_set],
    difficulty: :easy
  },
  %{
    id: "collections/set-put",
    prompt: ~S{`input` is a MapSet of integers. Return a MapSet (not a list) containing all of input's elements plus the value 42.},
    solution: ~S{MapSet.put(input, 42)},
    checks: [
      {~S|MapSet.new([1])|, ~S|MapSet.new([1, 42])|},
      {~S|MapSet.new([42])|, ~S|MapSet.new([42])|},
      {~S|MapSet.new([])|, ~S|MapSet.new([42])|}
    ],
    tags: [:map_set],
    difficulty: :easy
  },
  %{
    id: "collections/set-member",
    prompt: ~S{`input` is a MapSet. Return true when it contains the atom :ok, false otherwise.},
    solution: ~S{MapSet.member?(input, :ok)},
    checks: [
      {~S|MapSet.new([:ok, :error])|, ~S|true|},
      {~S|MapSet.new([])|, ~S|false|}
    ],
    tags: [:map_set],
    difficulty: :easy
  },
  %{
    id: "collections/set-union",
    prompt: ~S|`input` is a 2-tuple {a, b} of MapSets. Return their union as a MapSet.|,
    solution: ~S{MapSet.union(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{MapSet.new([1, 2]), MapSet.new([2, 3])}|, ~S|MapSet.new([1, 2, 3])|},
      {~S|{MapSet.new([]), MapSet.new([])}|, ~S|MapSet.new([])|}
    ],
    tags: [:map_set],
    difficulty: :medium
  },
  %{
    id: "collections/set-intersection",
    prompt: ~S|`input` is a 2-tuple {a, b} of MapSets. Return a MapSet of the elements present in BOTH sets.|,
    solution: ~S{MapSet.intersection(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{MapSet.new([1, 2, 3]), MapSet.new([2, 3, 4])}|, ~S|MapSet.new([2, 3])|},
      {~S|{MapSet.new([1]), MapSet.new([2])}|, ~S|MapSet.new([])|}
    ],
    tags: [:map_set],
    difficulty: :medium
  },
  %{
    id: "collections/set-difference",
    prompt: ~S|`input` is a 2-tuple {a, b} of MapSets. Return a MapSet of the elements of a that are NOT in b.|,
    solution: ~S{MapSet.difference(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{MapSet.new([1, 2, 3]), MapSet.new([2])}|, ~S|MapSet.new([1, 3])|},
      {~S|{MapSet.new([]), MapSet.new([1])}|, ~S|MapSet.new([])|}
    ],
    tags: [:map_set],
    difficulty: :medium
  },
  %{
    id: "collections/set-subset",
    prompt: ~S|`input` is a 2-tuple {a, b} of MapSets. Return true when every element of a is also in b, false otherwise (the empty set is a subset of every set).|,
    solution: ~S{MapSet.subset?(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{MapSet.new([1, 2]), MapSet.new([1, 2, 3])}|, ~S|true|},
      {~S|{MapSet.new([1, 4]), MapSet.new([1, 2, 3])}|, ~S|false|},
      {~S|{MapSet.new([]), MapSet.new([1])}|, ~S|true|}
    ],
    tags: [:map_set],
    difficulty: :medium
  },
  %{
    id: "collections/set-distinct-graphemes",
    prompt: ~S{`input` is a string. Return the number of DISTINCT graphemes it contains, as an integer.},
    solution: ~S{input |> String.graphemes() |> MapSet.new() |> MapSet.size()},
    checks: [
      {~S|"banana"|, ~S|3|},
      {~S|""|, ~S|0|},
      {~S|"héé"|, ~S|2|}
    ],
    tags: [:map_set],
    difficulty: :medium
  },

  # ── Tuple ──────────────────────────────────────────────────────────────
  %{
    id: "collections/tuple-elem",
    prompt: ~S{`input` is a tuple with at least two elements. Return the element at index 1 (zero-based).},
    solution: ~S{elem(input, 1)},
    checks: [
      {~S|{:a, :b, :c}|, ~S|:b|},
      {~S|{1, 2}|, ~S|2|}
    ],
    tags: [:tuple],
    difficulty: :easy
  },
  %{
    id: "collections/tuple-put-elem",
    prompt: ~S{`input` is a non-empty tuple. Return it with the element at index 0 (zero-based) replaced by the atom :new.},
    solution: ~S{put_elem(input, 0, :new)},
    checks: [
      {~S|{1, 2, 3}|, ~S|{:new, 2, 3}|},
      {~S|{:only}|, ~S|{:new}|}
    ],
    tags: [:tuple],
    difficulty: :medium
  },
  %{
    id: "collections/tuple-count",
    prompt: ~S{`input` is a tuple. Return the number of elements it contains, as an integer.},
    solution: ~S{tuple_size(input)},
    checks: [
      {~S|{}|, ~S|0|},
      {~S|{1, 2, 3}|, ~S|3|}
    ],
    tags: [:tuple, :trap],
    difficulty: :easy
  },
  %{
    id: "collections/tuple-sum",
    prompt: ~S{`input` is a tuple of integers. Return the sum of its elements as an integer (0 for the empty tuple).},
    solution: ~S{input |> Tuple.to_list() |> Enum.sum()},
    checks: [
      {~S|{1, 2, 3}|, ~S|6|},
      {~S|{}|, ~S|0|},
      {~S|{-5}|, ~S|-5|}
    ],
    tags: [:tuple, :gotcha],
    difficulty: :medium
  },
  %{
    id: "collections/tuple-from-list",
    prompt: ~S{`input` is a list. Return a tuple containing the same elements in the same order.},
    solution: ~S{List.to_tuple(input)},
    checks: [
      {~S|[1, 2]|, ~S|{1, 2}|},
      {~S|[]|, ~S|{}|}
    ],
    tags: [:tuple],
    difficulty: :easy
  },
  %{
    id: "collections/tuple-insert-at",
    prompt: ~S{`input` is a non-empty tuple. Return it with the atom :x inserted at index 1 (zero-based), shifting later elements one position to the right; for a one-element tuple :x becomes the last element.},
    solution: ~S{Tuple.insert_at(input, 1, :x)},
    checks: [
      {~S|{:a, :b}|, ~S|{:a, :x, :b}|},
      {~S|{:a}|, ~S|{:a, :x}|}
    ],
    tags: [:tuple],
    difficulty: :medium
  }
]
