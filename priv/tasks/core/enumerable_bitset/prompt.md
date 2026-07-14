Implement a compact integer set backed by a single integer bitmask, integrated with Elixir's `Enumerable` protocol.

Define a struct `BitSet` (field layout is up to you, but it must be a struct) with:

- `new/0` — the empty set; `new/1` — from an enumerable of non-negative integers.
- `put(set, n)` — add non-negative integer `n`.
- `member?(set, n)` — boolean.

Then implement the `Enumerable` protocol for `BitSet` so that all of `Enum` works on it:

- Iteration yields the members in **ascending order**.
- `Enum.count/1` must be O(popcount) or better — and must NOT go through reduce (implement the `count/1` protocol callback properly).
- `Enum.member?/2` must go through your `member?/2` logic (implement the `member?/2` protocol callback properly, not the default reduce fallback).
- Halting must work: `Enum.take(set, 2)` on a large set must not iterate everything.

Examples:

    BitSet.new([5, 1, 3]) |> Enum.to_list()   #=> [1, 3, 5]
    BitSet.new([1, 3]) |> Enum.count()          #=> 2
    5 in BitSet.new([5])                         #=> true
    BitSet.new(0..1000) |> Enum.take(3)         #=> [0, 1, 2]
