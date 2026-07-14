Write a module `ParallelMap` with a function `map/3` that maps a function over a list concurrently, with bounded concurrency and a per-element timeout.

`map(list, fun, opts)` where `opts` is a keyword list with:

- `:max_concurrency` (required, positive integer) — at most this many `fun` invocations run at the same time.
- `:timeout` (required, milliseconds) — per-element budget.

Semantics:

- Returns a list in the **original element order** (regardless of completion order), where each slot is:
  - `{:ok, result}` if `fun.(element)` returned normally within the timeout,
  - `{:error, :timeout}` if it ran out of time,
  - `{:error, :crashed}` if it raised or exited.
- One slow or crashing element must not affect the results of the others.
- The caller process must not crash and must not be left with stray messages in its mailbox.
- After a timeout, the corresponding worker process must actually be terminated (no zombie work left running).

Example:

    ParallelMap.map([10, 0, 20], fn ms -> Process.sleep(ms); ms * 2 end,
      max_concurrency: 2, timeout: 1_000)
    #=> [{:ok, 20}, {:ok, 0}, {:ok, 40}]
