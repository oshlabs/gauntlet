Build a small supervised worker system in one module file. Define:

1. `Watchdog.Worker` — a GenServer holding a counter, registered under a name passed at start:
   - `start_link(opts)` — `opts` contains `:name` (an atom to register under).
   - `increment(name)` — bumps the counter, returns the new value.
   - `value(name)` — current counter value (starts at 0).
   - `crash(name)` — makes the worker process exit abnormally (the caller must survive making this call).

2. `Watchdog` — a Supervisor:
   - `start_link(opts)` — starts the supervisor, which supervises **two** `Watchdog.Worker` children named `:wd_alpha` and `:wd_beta`, using a strategy where **one crashing child is restarted alone** (the sibling must keep its state).
   - Restarted workers come back registered under their name, with the counter reset to 0.

Notes:

- You may define both modules in one reply (they are one file).
- Do not use `Process.flag(:trap_exit, true)` in the caller as a substitute for a real supervisor.
- The supervisor must tolerate rapid successive crashes during a test run (choose sensible restart intensity).
