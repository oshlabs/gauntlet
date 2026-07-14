Build an on-demand counter farm using `Registry` and `DynamicSupervisor` (both from the standard library — do not hand-roll process registration with `Process.register/2`).

Define (all in one reply, they are one file):

- `CounterFarm.start_link(opts \\ [])` — starts the farm: a supervision tree containing a `Registry` (unique keys) and a `DynamicSupervisor`. Only ONE farm instance will be started per test run; its internal names are up to you.
- `CounterFarm.incr(id)` — increments the counter for term `id` (any term, not just atoms) and returns the new value. If no counter process exists for `id` yet, one is started on demand under the DynamicSupervisor, starting from 0 (so the first `incr` returns 1).
- `CounterFarm.value(id)` — current value; `0` if no counter process exists for `id`.
- `CounterFarm.which(id)` — `{:ok, pid}` of the counter process for `id`, or `:error` if none.
- `CounterFarm.count()` — how many counter processes are alive.

Requirements:

- Counter processes must be registered via the Registry (`:via` tuples), keyed by `id`.
- Concurrent `incr(id)` calls for the SAME brand-new `id` must not crash or lose increments: exactly one process gets started (handle the start race), and every call is counted.
- Counters for different ids are independent processes: `count()` reflects distinct ids used.
