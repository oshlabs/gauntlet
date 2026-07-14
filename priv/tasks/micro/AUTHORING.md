# Authoring micro knowledge items

Micro items are tiny probes of Elixir language + stdlib knowledge: the
model answers with a **single expression**, which gets spliced into:

```elixir
defmodule Micro do
  def solve(input) do
    _ = input
    __SNIPPET__      # <- the model's answer
  end
end
```

and graded by generated ExUnit tests. Items live in themed `<theme>.exs`
files in this directory, each evaluating to a list of maps:

```elixir
[
  %{
    id: "enum/double",       # "<theme>/<slug>", unique across the whole pack
    prompt: ~S{`input` is a list of numbers. Return a list with every value doubled.},
    solution: ~S{Enum.map(input, &(&1 * 2))},
    checks: [
      {~S{[1, 2, 3]}, ~S{[2, 4, 6]}},   # {input literal, expected literal}
      {~S{[]}, ~S{[]}}                   # always include an edge case
    ],
    tags: [:enum],
    difficulty: :easy        # :easy | :medium | :hard (no :smoke here)
  }
]
```

Each `{input, expected}` check becomes `input = <input>; assert
Micro.solve(input) == (<expected>)`. For raise-assertions use
`raw_checks: [~S{assert_raise ArgumentError, fn -> Micro.solve("x") end}]`.

## Rules

1. **The prompt must fully determine the observable behaviour.** The model
   cannot see the checks. Name the input binding (`input`), its type, and
   the exact expected result semantics. Mention result type when ambiguous
   (list vs map, string vs charlist, integer vs float).
2. **2–3 checks per item**, at least one edge case (empty collection, zero,
   unicode, negative number, missing key). Checks are literals — keep them
   deterministic (no clock, no randomness, no pid values, no map ordering
   assumptions beyond `==`).
3. **One expression answers it.** If the natural solution needs multiple
   statements or a module, it belongs in the `core` pack, not here.
   Pipes and `case`/`if` expressions are fine.
4. **Reference solution required** — `mix gauntlet.validate --suite micro`
   executes it against the checks in the real sandbox; a failing reference
   means the item is broken.
5. **Ask for behaviour, not for a specific function**, unless the function
   IS the knowledge being tested. Both styles are welcome; tag
   function-specific items with the module tag (`:enum`, `:string`, …).
6. **Traps are encouraged** (tag `:trap`): prompts where the plausible
   first instinct is a function that does not exist or was removed
   (`String.strip/1`, `Enum.filter_map/3`) — the checks only pass with the
   real API. Never *mention* the fake function in the prompt; the trap is
   that the model reaches for it.
7. **No third-party libraries, no Mix, no filesystem/network** in either
   solutions or checks. Erlang stdlib via `:math`, `:binary`, `:rand`
   (seeded) etc. is allowed where idiomatic.
8. **Difficulty calibration**: `:easy` = any Elixir programmer answers
   instantly (String.upcase); `:medium` = requires actually knowing the
   API/semantics (Enum.chunk_every step, Range step syntax, charlist
   printing); `:hard` = corner semantics people get wrong (negative rem,
   binary size/unit, Keyword duplicate keys, float rounding, struct
   Access).
9. Items in one file must have unique ids; the loader enforces pack-wide
   uniqueness too. Keep ids stable — they are the cross-run comparison key
   and changing content changes the suite hash.
