# Micro items: runtime behaviour — processes & messaging, Task & Agent,
# errors & exceptions, built-in structs / protocols / misc.
#
# Determinism notes: no assertions on pid values; every concurrent solution
# is synchronized via await/receive/monitor; the only timer-based items use
# tiny send_after delays with generous receive timeouts; receive patterns
# are specific so items never consume each other's stray messages.

[
  # ── Processes & messaging ────────────────────────────────────────────────
  %{
    id: "runtime/send-self-receive",
    prompt: ~S"""
    `input` is any term. Write an expression (a short block is fine) that sends the tuple `{:echo, input}` to the current process, then receives a message matching `{:echo, _}` and returns the whole received tuple.
    """,
    solution: ~S"""
    send(self(), {:echo, input})
    receive do
      {:echo, _} = msg -> msg
    end
    """,
    checks: [
      {~S|:hi|, ~S|{:echo, :hi}|},
      {~S|nil|, ~S|{:echo, nil}|},
      {~S|[1, 2]|, ~S|{:echo, [1, 2]}|}
    ],
    tags: [:process],
    difficulty: :easy
  },
  %{
    id: "runtime/receive-after-zero",
    prompt: ~S"""
    The current process's mailbox contains no `:ping` message (`input` is ignored). Write an expression that tries to receive the atom `:ping` and return it, but returns `:empty` immediately — without blocking — when no such message is waiting.
    """,
    solution: ~S"""
    receive do
      :ping -> :ping
    after
      0 -> :empty
    end
    """,
    checks: [
      {~S|nil|, ~S|:empty|},
      {~S|:whatever|, ~S|:empty|}
    ],
    tags: [:process],
    difficulty: :easy
  },
  %{
    id: "runtime/selective-receive",
    prompt: ~S"""
    `input` is any term. Write a short block that sends `{:noise, :junk}` to the current process, then sends `{:data, input}`, then receives only a message matching `{:data, _}` — the noise message must stay in the mailbox — and returns the payload of the data message.
    """,
    solution: ~S"""
    send(self(), {:noise, :junk})
    send(self(), {:data, input})
    receive do
      {:data, v} -> v
    end
    """,
    checks: [
      {~S|42|, ~S|42|},
      {~S|"x"|, ~S|"x"|},
      {~S|nil|, ~S|nil|}
    ],
    tags: [:process],
    difficulty: :medium
  },
  %{
    id: "runtime/spawn-report-parent",
    prompt: ~S"""
    `input` is an integer. Write a short block that spawns a new process which computes `input * 2` and sends `{:result, value}` back to the parent process (the one running the block), then receives the result tuple in the parent and returns the value.
    """,
    solution: ~S"""
    parent = self()
    spawn(fn -> send(parent, {:result, input * 2}) end)
    receive do
      {:result, v} -> v
    end
    """,
    checks: [
      {~S|3|, ~S|6|},
      {~S|0|, ~S|0|},
      {~S|-2|, ~S|-4|}
    ],
    tags: [:process],
    difficulty: :hard
  },
  %{
    id: "runtime/spawn-returns-pid",
    prompt: ~S"""
    `input` is ignored. Spawn a process whose body is just `:ok` and return a boolean: whether the value the spawn call gave you back is a pid.
    """,
    solution: ~S|is_pid(spawn(fn -> :ok end))|,
    checks: [
      {~S|nil|, ~S|true|},
      {~S|0|, ~S|true|}
    ],
    tags: [:process],
    difficulty: :easy
  },
  %{
    id: "runtime/alive-after-down",
    prompt: ~S"""
    `input` is ignored. Write a short block that spawns a monitored process whose body is just `:ok`, waits for the corresponding `:DOWN` message, and then returns a boolean: whether the spawned process is still alive.
    """,
    solution: ~S"""
    {pid, ref} = spawn_monitor(fn -> :ok end)
    receive do
      {:DOWN, ^ref, :process, ^pid, _reason} -> Process.alive?(pid)
    end
    """,
    checks: [
      {~S|nil|, ~S|false|},
      {~S|:x|, ~S|false|}
    ],
    tags: [:process],
    difficulty: :medium
  },
  %{
    id: "runtime/monitor-down-reason",
    prompt: ~S"""
    `input` is ignored. Write a short block that spawns a monitored process which finishes immediately and normally, receives the `{:DOWN, ref, :process, pid, reason}` message for it, and returns the reason.
    """,
    solution: ~S"""
    {pid, ref} = spawn_monitor(fn -> :ok end)
    receive do
      {:DOWN, ^ref, :process, ^pid, reason} -> reason
    end
    """,
    checks: [
      {~S|nil|, ~S|:normal|},
      {~S|1|, ~S|:normal|}
    ],
    tags: [:process],
    difficulty: :medium
  },
  %{
    id: "runtime/make-ref-unique",
    prompt: ~S"""
    `input` is ignored. Create two fresh unique references and return a boolean: whether they compare equal.
    """,
    solution: ~S|make_ref() == make_ref()|,
    checks: [
      {~S|nil|, ~S|false|},
      {~S|:x|, ~S|false|}
    ],
    tags: [:process],
    difficulty: :easy
  },
  %{
    id: "runtime/send-after-not-yet",
    prompt: ~S"""
    `input` is ignored. Write a short block that schedules the atom `:tick` to be delivered to the current process only after 5000 milliseconds, then immediately — without waiting at all — checks the mailbox: return `:already` if `:tick` has arrived, `:not_yet` otherwise.
    """,
    solution: ~S"""
    Process.send_after(self(), :tick, 5000)
    receive do
      :tick -> :already
    after
      0 -> :not_yet
    end
    """,
    checks: [
      {~S|nil|, ~S|:not_yet|},
      {~S|0|, ~S|:not_yet|}
    ],
    tags: [:process],
    difficulty: :hard
  },
  %{
    id: "runtime/send-after-delivered",
    prompt: ~S"""
    `input` is any term. Write a short block that schedules the tuple `{:tick, input}` to be delivered to the current process after 10 milliseconds, then receives a `{:tick, _}` message with a 500 millisecond timeout, returning the payload — or `:timeout` if nothing arrives in time.
    """,
    solution: ~S"""
    Process.send_after(self(), {:tick, input}, 10)
    receive do
      {:tick, v} -> v
    after
      500 -> :timeout
    end
    """,
    checks: [
      {~S|:a|, ~S|:a|},
      {~S|7|, ~S|7|}
    ],
    tags: [:process],
    difficulty: :medium
  },
  %{
    id: "runtime/mailbox-fifo",
    prompt: ~S"""
    `input` is ignored. Write a short block that sends `{:seq, 1}` and then `{:seq, 2}` to the current process, performs two receives each matching `{:seq, n}`, and returns the two payloads as a list in the order they were received (mailbox delivery from one sender is FIFO).
    """,
    solution: ~S"""
    send(self(), {:seq, 1})
    send(self(), {:seq, 2})
    a = receive do {:seq, n} -> n end
    b = receive do {:seq, n} -> n end
    [a, b]
    """,
    checks: [
      {~S|nil|, ~S|[1, 2]|},
      {~S|:x|, ~S|[1, 2]|}
    ],
    tags: [:process],
    difficulty: :easy
  },
  %{
    id: "runtime/send-return-value",
    prompt: ~S"""
    `input` is any term. Write a short block that sends the tuple `{:sent, input}` to the current process and captures the return value of the send operation itself. Then receive the `{:sent, _}` message (so the mailbox is left clean) and return the captured value.
    """,
    solution: ~S"""
    result = send(self(), {:sent, input})
    receive do
      {:sent, _} -> :ok
    end
    result
    """,
    checks: [
      {~S|1|, ~S|{:sent, 1}|},
      {~S|nil|, ~S|{:sent, nil}|}
    ],
    tags: [:process],
    difficulty: :hard
  },
  %{
    id: "runtime/trap-force-kill",
    prompt: ~S"""
    `input` is ignored. Write a short block that spawns a monitored process that blocks forever in a `receive`, forcefully and unconditionally terminates it (a termination the process cannot trap or ignore), waits for the resulting `:DOWN` message, and returns the exit reason atom from that message.
    """,
    solution: ~S"""
    {pid, ref} = spawn_monitor(fn -> receive do :never -> :ok end end)
    Process.exit(pid, :kill)
    receive do
      {:DOWN, ^ref, :process, ^pid, reason} -> reason
    end
    """,
    checks: [
      {~S|nil|, ~S|:killed|},
      {~S|:x|, ~S|:killed|}
    ],
    tags: [:process, :trap],
    difficulty: :hard
  },
  %{
    id: "runtime/trap-still-running",
    prompt: ~S"""
    `input` is ignored. Write a short block that spawns a process that blocks forever waiting in a `receive`, then returns a boolean: whether that spawned process is currently running.
    """,
    solution: ~S"""
    pid = spawn(fn -> receive do :never -> :ok end end)
    Process.alive?(pid)
    """,
    checks: [
      {~S|nil|, ~S|true|},
      {~S|0|, ~S|true|}
    ],
    tags: [:process, :trap],
    difficulty: :medium
  },

  # ── Task & Agent ─────────────────────────────────────────────────────────
  %{
    id: "runtime/task-async-await",
    prompt: ~S"""
    `input` is an integer. Compute `input * 3` in a concurrently running task and return the awaited result.
    """,
    solution: ~S"""
    Task.async(fn -> input * 3 end) |> Task.await()
    """,
    checks: [
      {~S|2|, ~S|6|},
      {~S|0|, ~S|0|},
      {~S|-1|, ~S|-3|}
    ],
    tags: [:task],
    difficulty: :easy
  },
  %{
    id: "runtime/task-await-many",
    prompt: ~S"""
    `input` is a `{a, b}` tuple of integers. Write a short block that starts two tasks concurrently — one computing `a * 10`, one computing `b * 10` — waits for both with a single call, and returns the list of results in the order the tasks were started.
    """,
    solution: ~S"""
    {a, b} = input
    Task.await_many([Task.async(fn -> a * 10 end), Task.async(fn -> b * 10 end)])
    """,
    checks: [
      {~S|{1, 2}|, ~S|[10, 20]|},
      {~S|{0, -3}|, ~S|[0, -30]|}
    ],
    tags: [:task],
    difficulty: :medium
  },
  %{
    id: "runtime/task-async-stream",
    prompt: ~S"""
    `input` is a list of integers. Square each element using the Task-based stream that runs at most 2 tasks concurrently, then collect the plain squared values into a list preserving input order (each stream element arrives as `{:ok, value}`).
    """,
    solution: ~S"""
    input
    |> Task.async_stream(&(&1 * &1), max_concurrency: 2)
    |> Enum.map(fn {:ok, v} -> v end)
    """,
    checks: [
      {~S|[1, 2, 3]|, ~S|[1, 4, 9]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:task],
    difficulty: :medium
  },
  %{
    id: "runtime/agent-start-get",
    prompt: ~S"""
    `input` is any term. Write a short block that starts an Agent holding `input` as its state, then returns the state read back from the Agent.
    """,
    solution: ~S"""
    {:ok, pid} = Agent.start_link(fn -> input end)
    Agent.get(pid, & &1)
    """,
    checks: [
      {~S|42|, ~S|42|},
      {~S|"x"|, ~S|"x"|},
      {~S|nil|, ~S|nil|}
    ],
    tags: [:agent],
    difficulty: :easy
  },
  %{
    id: "runtime/agent-update-get",
    prompt: ~S"""
    `input` is an integer. Write a short block that starts an Agent with state `input`, adds 10 to its state via an update, and returns the Agent's state afterwards.
    """,
    solution: ~S"""
    {:ok, pid} = Agent.start_link(fn -> input end)
    Agent.update(pid, &(&1 + 10))
    Agent.get(pid, & &1)
    """,
    checks: [
      {~S|5|, ~S|15|},
      {~S|-10|, ~S|0|}
    ],
    tags: [:agent],
    difficulty: :easy
  },
  %{
    id: "runtime/agent-counter-n",
    prompt: ~S"""
    `input` is a non-negative integer. Write a short block that starts an Agent counter at 0, increments it by 1 exactly `input` times (zero times when `input` is 0), and returns the final counter value read from the Agent.
    """,
    solution: ~S"""
    {:ok, pid} = Agent.start_link(fn -> 0 end)
    Enum.each(1..input//1, fn _ -> Agent.update(pid, &(&1 + 1)) end)
    Agent.get(pid, & &1)
    """,
    checks: [
      {~S|3|, ~S|3|},
      {~S|0|, ~S|0|},
      {~S|1|, ~S|1|}
    ],
    tags: [:agent],
    difficulty: :hard
  },
  %{
    id: "runtime/agent-get-and-update",
    prompt: ~S"""
    `input` is an integer. Write a short block that starts an Agent with state `input`, then — in one atomic Agent operation — retrieves the current state while replacing it with the state plus 1. Return `{retrieved, after}` where `retrieved` is what the atomic operation gave back and `after` is the Agent's state read afterwards.
    """,
    solution: ~S"""
    {:ok, pid} = Agent.start_link(fn -> input end)
    old = Agent.get_and_update(pid, fn s -> {s, s + 1} end)
    {old, Agent.get(pid, & &1)}
    """,
    checks: [
      {~S|5|, ~S|{5, 6}|},
      {~S|0|, ~S|{0, 1}|}
    ],
    tags: [:agent],
    difficulty: :medium
  },
  %{
    id: "runtime/task-async-mfa",
    prompt: ~S"""
    `input` is a lowercase string. Start a task by passing a module, a function name, and an argument list (not an anonymous function) so the task upcases `input`; await it and return the result.
    """,
    solution: ~S"""
    Task.async(String, :upcase, [input]) |> Task.await()
    """,
    checks: [
      {~S|"abc"|, ~S|"ABC"|},
      {~S|""|, ~S|""|}
    ],
    tags: [:task],
    difficulty: :medium
  },
  %{
    id: "runtime/task-yield-ok",
    prompt: ~S"""
    `input` is an integer. Write a short block that starts a task computing `input * 2`, then waits up to 1000 milliseconds for it using the Task function that returns `{:ok, result}` if the task has finished by then (or `nil` if it has not) — return exactly what that function returns.
    """,
    solution: ~S"""
    task = Task.async(fn -> input * 2 end)
    Task.yield(task, 1000)
    """,
    checks: [
      {~S|3|, ~S|{:ok, 6}|},
      {~S|0|, ~S|{:ok, 0}|}
    ],
    tags: [:task],
    difficulty: :hard
  },
  %{
    id: "runtime/agent-list-prepend",
    prompt: ~S"""
    `input` is any term. Write a short block that starts an Agent holding an empty list, prepends `input` to the list, then prepends the atom `:done`, and returns the final list read from the Agent.
    """,
    solution: ~S"""
    {:ok, pid} = Agent.start_link(fn -> [] end)
    Agent.update(pid, &[input | &1])
    Agent.update(pid, &[:done | &1])
    Agent.get(pid, & &1)
    """,
    checks: [
      {~S|:a|, ~S|[:done, :a]|},
      {~S|nil|, ~S|[:done, nil]|}
    ],
    tags: [:agent],
    difficulty: :easy
  },
  %{
    id: "runtime/trap-task-block",
    prompt: ~S"""
    `input` is a list. Start a task that reverses the list, then block until the task finishes and return its result.
    """,
    solution: ~S"""
    Task.async(fn -> Enum.reverse(input) end) |> Task.await()
    """,
    checks: [
      {~S|[1, 2, 3]|, ~S|[3, 2, 1]|},
      {~S|[]|, ~S|[]|}
    ],
    tags: [:task, :trap],
    difficulty: :easy
  },
  %{
    id: "runtime/trap-agent-replace",
    prompt: ~S"""
    `input` is any term. Write a short block that starts an Agent whose initial state is the atom `:initial`, replaces the Agent's state entirely with `input`, and returns the Agent's current state.
    """,
    solution: ~S"""
    {:ok, pid} = Agent.start_link(fn -> :initial end)
    Agent.update(pid, fn _ -> input end)
    Agent.get(pid, & &1)
    """,
    checks: [
      {~S|42|, ~S|42|},
      {~S|nil|, ~S|nil|},
      {~S|"state"|, ~S|"state"|}
    ],
    tags: [:agent, :trap],
    difficulty: :medium
  },

  # ── Errors & exceptions ──────────────────────────────────────────────────
  %{
    id: "runtime/rescue-fallback",
    prompt: ~S"""
    `input` is a string. Return the integer it represents; if the conversion raises, return 0 instead.
    """,
    solution: ~S"""
    try do
      String.to_integer(input)
    rescue
      _ -> 0
    end
    """,
    checks: [
      {~S|"42"|, ~S|42|},
      {~S|"abc"|, ~S|0|},
      {~S|"-3"|, ~S|-3|}
    ],
    tags: [:error],
    difficulty: :easy
  },
  %{
    id: "runtime/rescue-in-message",
    prompt: ~S"""
    `input` is ignored. Write a short block that raises an `ArgumentError` with message "bad input" inside a `try`, rescues specifically `ArgumentError` (binding the exception to a variable), and returns the rescued exception's message string.
    """,
    solution: ~S"""
    try do
      raise ArgumentError, "bad input"
    rescue
      e in ArgumentError -> Exception.message(e)
    end
    """,
    checks: [
      {~S|nil|, ~S|"bad input"|},
      {~S|:x|, ~S|"bad input"|}
    ],
    tags: [:error],
    difficulty: :medium
  },
  %{
    id: "runtime/raise-argument-error",
    prompt: ~S"""
    `input` is an integer. If it is negative, raise an `ArgumentError` whose message is exactly "negative: " followed by the integer (e.g. "negative: -1"); otherwise return `input` unchanged.
    """,
    solution: ~S"""
    if input < 0, do: raise(ArgumentError, "negative: #{input}"), else: input
    """,
    checks: [
      {~S|5|, ~S|5|},
      {~S|0|, ~S|0|}
    ],
    raw_checks: [
      ~S|assert_raise ArgumentError, "negative: -1", fn -> Micro.solve(-1) end|
    ],
    tags: [:error],
    difficulty: :medium
  },
  %{
    id: "runtime/catch-throw-value",
    prompt: ~S"""
    `input` is any term. Write an expression that throws the tuple `{:early, input}` inside a `try` and catches the thrown value, returning it.
    """,
    solution: ~S"""
    try do
      throw({:early, input})
    catch
      :throw, v -> v
    end
    """,
    checks: [
      {~S|1|, ~S|{:early, 1}|},
      {~S|nil|, ~S|{:early, nil}|}
    ],
    tags: [:error],
    difficulty: :medium
  },
  %{
    id: "runtime/reduce-while-cap",
    prompt: ~S"""
    `input` is a list of positive integers. Accumulate a running sum from the left, but stop before adding any element that would push the sum above 10; return the sum accumulated so far. The idiomatic solution halts the reduction early rather than throwing.
    """,
    solution: ~S"""
    Enum.reduce_while(input, 0, fn x, acc ->
      if acc + x > 10, do: {:halt, acc}, else: {:cont, acc + x}
    end)
    """,
    checks: [
      {~S|[4, 5, 6]|, ~S|9|},
      {~S|[]|, ~S|0|},
      {~S|[20]|, ~S|0|}
    ],
    tags: [:enum, :error],
    difficulty: :medium
  },
  %{
    id: "runtime/throw-early-exit",
    prompt: ~S"""
    `input` is a list of integers. Using `throw` and `catch` as a non-local early exit (iterate with `Enum.each`, not a reduce), return the first element greater than 100, or `:none` when there is none.
    """,
    solution: ~S"""
    try do
      Enum.each(input, fn x -> if x > 100, do: throw(x) end)
      :none
    catch
      x -> x
    end
    """,
    checks: [
      {~S|[1, 200, 300]|, ~S|200|},
      {~S|[1, 2]|, ~S|:none|},
      {~S|[]|, ~S|:none|}
    ],
    tags: [:error],
    difficulty: :hard
  },
  %{
    id: "runtime/catch-exit-reason",
    prompt: ~S"""
    `input` is ignored. Write an expression that calls `exit(:boom)` inside a `try` and catches the exit, returning `{:exited, reason}` where `reason` is the exit reason.
    """,
    solution: ~S"""
    try do
      exit(:boom)
    catch
      :exit, reason -> {:exited, reason}
    end
    """,
    checks: [
      {~S|nil|, ~S|{:exited, :boom}|},
      {~S|1|, ~S|{:exited, :boom}|}
    ],
    tags: [:error],
    difficulty: :medium
  },
  %{
    id: "runtime/after-always-runs",
    prompt: ~S"""
    `input` is ignored. Write a short block: inside a `try`, raise a `RuntimeError`; rescue it, producing `:rescued`; and in the `after` clause send the atom `:cleanup` to the current process. After the `try`, check the mailbox for `:cleanup` without blocking and return `{try_result, :cleanup}` if it arrived or `{try_result, :missing}` if it did not.
    """,
    solution: ~S"""
    result =
      try do
        raise "boom"
      rescue
        _ -> :rescued
      after
        send(self(), :cleanup)
      end

    seen =
      receive do
        :cleanup -> :cleanup
      after
        0 -> :missing
      end

    {result, seen}
    """,
    checks: [
      {~S|nil|, ~S|{:rescued, :cleanup}|},
      {~S|:x|, ~S|{:rescued, :cleanup}|}
    ],
    tags: [:error, :process],
    difficulty: :hard
  },
  %{
    id: "runtime/map-fetch-tuple",
    prompt: ~S"""
    `input` is a map. Look up the key `:name`, returning `{:ok, value}` when the key is present and `:error` when it is absent.
    """,
    solution: ~S|Map.fetch(input, :name)|,
    checks: [
      {~S|%{name: "ada"}|, ~S|{:ok, "ada"}|},
      {~S|%{}|, ~S|:error|}
    ],
    tags: [:map, :error],
    difficulty: :easy
  },
  %{
    id: "runtime/map-fetch-bang",
    prompt: ~S"""
    `input` is a map. Return the value stored under the key `:id`; when the key is absent a `KeyError` must be raised.
    """,
    solution: ~S|Map.fetch!(input, :id)|,
    checks: [
      {~S|%{id: 7}|, ~S|7|},
      {~S|%{id: nil}|, ~S|nil|}
    ],
    raw_checks: [
      ~S|assert_raise KeyError, fn -> Micro.solve(%{}) end|
    ],
    tags: [:map, :error],
    difficulty: :easy
  },
  %{
    id: "runtime/string-to-integer-strict",
    prompt: ~S"""
    `input` is a string. Convert it to an integer; input that is not a valid integer must raise an `ArgumentError`.
    """,
    solution: ~S|String.to_integer(input)|,
    checks: [
      {~S|"42"|, ~S|42|},
      {~S|"-7"|, ~S|-7|}
    ],
    raw_checks: [
      ~S|assert_raise ArgumentError, fn -> Micro.solve("4x") end|
    ],
    tags: [:string, :error],
    difficulty: :easy
  },
  %{
    id: "runtime/integer-parse-raw",
    prompt: ~S"""
    `input` is a string. Return the result of parsing a leading integer off it: a tuple of the integer and the unparsed remainder string, or `:error` when the string has no leading integer.
    """,
    solution: ~S|Integer.parse(input)|,
    checks: [
      {~S|"42abc"|, ~S|{42, "abc"}|},
      {~S|"10"|, ~S|{10, ""}|},
      {~S|"x"|, ~S|:error|}
    ],
    tags: [:integer, :error],
    difficulty: :easy
  },
  %{
    id: "runtime/parse-ok-error",
    prompt: ~S"""
    `input` is a string. Return `{:ok, n}` when the entire string is a valid integer `n` (no trailing characters allowed), and `:error` otherwise.
    """,
    solution: ~S"""
    case Integer.parse(input) do
      {n, ""} -> {:ok, n}
      _ -> :error
    end
    """,
    checks: [
      {~S|"42"|, ~S|{:ok, 42}|},
      {~S|"42x"|, ~S|:error|},
      {~S|""|, ~S|:error|}
    ],
    tags: [:integer, :error],
    difficulty: :medium
  },
  %{
    id: "runtime/rescue-runtime-message",
    prompt: ~S"""
    `input` is a string. Raise it as a plain runtime error message (raising with just the string), rescue any exception, and return the message extracted from the rescued exception.
    """,
    solution: ~S"""
    try do
      raise input
    rescue
      e -> Exception.message(e)
    end
    """,
    checks: [
      {~S|"oops"|, ~S|"oops"|},
      {~S|""|, ~S|""|}
    ],
    tags: [:error],
    difficulty: :medium
  },
  %{
    id: "runtime/rescue-arithmetic-only",
    prompt: ~S"""
    `input` is a `{a, b}` tuple of integers. Return `a` integer-divided by `b`, but when the division fails arithmetically (division by zero) return `:undefined`. Rescue only the arithmetic error type, nothing broader.
    """,
    solution: ~S"""
    {a, b} = input
    try do
      div(a, b)
    rescue
      ArithmeticError -> :undefined
    end
    """,
    checks: [
      {~S|{10, 2}|, ~S|5|},
      {~S|{1, 0}|, ~S|:undefined|},
      {~S|{-9, 3}|, ~S|-3|}
    ],
    tags: [:error],
    difficulty: :hard
  },
  %{
    id: "runtime/try-else-wrap",
    prompt: ~S"""
    `input` is an integer. Using a `try` with both a `rescue` and an `else` clause: compute `div(100, input)` in the try body; when it raises an `ArithmeticError` return `:error`; when it succeeds, the `else` clause must wrap the successful value as `{:ok, value}`.
    """,
    solution: ~S"""
    try do
      div(100, input)
    rescue
      ArithmeticError -> :error
    else
      v -> {:ok, v}
    end
    """,
    checks: [
      {~S|4|, ~S|{:ok, 25}|},
      {~S|0|, ~S|:error|},
      {~S|-5|, ~S|{:ok, -20}|}
    ],
    tags: [:error],
    difficulty: :hard
  },

  # ── Structs, protocols, misc ─────────────────────────────────────────────
  %{
    id: "runtime/is-struct-date",
    prompt: ~S"""
    `input` is any term. Return `true` only when it is a `Date` struct, `false` for anything else (including plain maps with date-like keys).
    """,
    solution: ~S|is_struct(input, Date)|,
    checks: [
      {~S|~D[2024-01-01]|, ~S|true|},
      {~S|%{year: 2024, month: 1, day: 1}|, ~S|false|},
      {~S|nil|, ~S|false|}
    ],
    tags: [:struct, :date],
    difficulty: :easy
  },
  %{
    id: "runtime/map-from-struct-date",
    prompt: ~S"""
    `input` is a `Date` struct. Convert it to a plain map, dropping only the `__struct__` key and keeping every other field the struct carries.
    """,
    solution: ~S|Map.from_struct(input)|,
    checks: [
      {~S|~D[2024-01-15]|, ~S|%{calendar: Calendar.ISO, year: 2024, month: 1, day: 15}|},
      {~S|~D[1999-12-31]|, ~S|%{calendar: Calendar.ISO, year: 1999, month: 12, day: 31}|}
    ],
    tags: [:struct, :date],
    difficulty: :hard
  },
  %{
    id: "runtime/date-first-of-month",
    prompt: ~S"""
    `input` is a `Date` struct. Return a `Date` equal to it except with the day set to 1 (the first of the same month).
    """,
    solution: ~S"""
    %{input | day: 1}
    """,
    checks: [
      {~S|~D[2024-03-15]|, ~S|~D[2024-03-01]|},
      {~S|~D[2020-02-29]|, ~S|~D[2020-02-01]|}
    ],
    tags: [:struct, :date],
    difficulty: :medium
  },
  %{
    id: "runtime/uri-host",
    prompt: ~S"""
    `input` is a URL string. Parse it and return the host as a string.
    """,
    solution: ~S|URI.parse(input).host|,
    checks: [
      {~S|"https://example.com/x"|, ~S|"example.com"|},
      {~S|"http://sub.test.org:8080/"|, ~S|"sub.test.org"|}
    ],
    tags: [:uri],
    difficulty: :easy
  },
  %{
    id: "runtime/uri-port-path-query",
    prompt: ~S"""
    `input` is a URL string. Parse it and return the tuple `{port, path, query}` — the port as an integer (well-known scheme defaults apply when the URL names no port), the path as a string, and the query as a string or `nil` when absent.
    """,
    solution: ~S"""
    uri = URI.parse(input)
    {uri.port, uri.path, uri.query}
    """,
    checks: [
      {~S|"https://example.com:8080/api?x=1"|, ~S|{8080, "/api", "x=1"}|},
      {~S|"http://a.io/"|, ~S|{80, "/", nil}|},
      {~S|"https://x.org/a/b"|, ~S|{443, "/a/b", nil}|}
    ],
    tags: [:uri, :struct],
    difficulty: :hard
  },
  %{
    id: "runtime/date-pattern-match",
    prompt: ~S"""
    `input` is a `Date` struct. Using struct pattern matching, extract the year and month and return them as the tuple `{year, month}`.
    """,
    solution: ~S"""
    %Date{year: y, month: m} = input
    {y, m}
    """,
    checks: [
      {~S|~D[2024-03-15]|, ~S|{2024, 3}|},
      {~S|~D[1999-12-31]|, ~S|{1999, 12}|}
    ],
    tags: [:struct, :date],
    difficulty: :easy
  },
  %{
    id: "runtime/to-string-chars",
    prompt: ~S"""
    `input` is an integer or an atom. Return its string representation via the standard string-conversion protocol.
    """,
    solution: ~S|to_string(input)|,
    checks: [
      {~S|42|, ~S|"42"|},
      {~S|:hello|, ~S|"hello"|},
      {~S|-7|, ~S|"-7"|}
    ],
    tags: [:protocol],
    difficulty: :easy
  },
  %{
    id: "runtime/date-to-string",
    prompt: ~S"""
    `input` is a `Date` struct. Return its string-protocol conversion — the bare ISO 8601 date string, not the inspect form.
    """,
    solution: ~S|to_string(input)|,
    checks: [
      {~S|~D[2024-01-01]|, ~S|"2024-01-01"|},
      {~S|~D[0001-01-01]|, ~S|"0001-01-01"|}
    ],
    tags: [:protocol, :date],
    difficulty: :medium
  },
  %{
    id: "runtime/inspect-date-sigil",
    prompt: ~S"""
    `input` is a `Date` struct. Return the string that `inspect/1` produces for it.
    """,
    solution: ~S|inspect(input)|,
    checks: [
      {~S|~D[2024-01-01]|, ~S|"~D[2024-01-01]"|},
      {~S|~D[1999-12-31]|, ~S|"~D[1999-12-31]"|}
    ],
    tags: [:protocol, :date],
    difficulty: :easy
  },
  %{
    id: "runtime/enumerable-impl-check",
    prompt: ~S"""
    `input` is any term. Return `true` if `input`'s data type has an implementation of the `Enumerable` protocol, `false` otherwise — determine this without enumerating the value.
    """,
    solution: ~S|Enumerable.impl_for(input) != nil|,
    checks: [
      {~S|%{a: 1}|, ~S|true|},
      {~S|5|, ~S|false|},
      {~S|"abc"|, ~S|false|}
    ],
    tags: [:protocol],
    difficulty: :hard
  },
  %{
    id: "runtime/code-eval-value",
    prompt: ~S"""
    `input` is a string containing an Elixir arithmetic expression. Evaluate it at runtime and return only the resulting value (the evaluation API also reports bindings — discard those).
    """,
    solution: ~S"""
    Code.eval_string(input) |> elem(0)
    """,
    checks: [
      {~S|"1 + 2"|, ~S|3|},
      {~S|"10 * 10"|, ~S|100|},
      {~S|"5 - 8"|, ~S|-3|}
    ],
    tags: [:code],
    difficulty: :medium
  },
  %{
    id: "runtime/version-compare-semver",
    prompt: ~S"""
    `input` is a `{v1, v2}` tuple of version strings like "1.2.3". Compare them as semantic versions (not lexicographically) and return `:lt`, `:eq`, or `:gt`.
    """,
    solution: ~S"""
    {a, b} = input
    Version.compare(a, b)
    """,
    checks: [
      {~S|{"1.2.3", "1.10.0"}|, ~S|:lt|},
      {~S|{"2.0.0", "2.0.0"}|, ~S|:eq|},
      {~S|{"0.10.0", "0.9.9"}|, ~S|:gt|}
    ],
    tags: [:version],
    difficulty: :hard
  },
  %{
    id: "runtime/version-match-req",
    prompt: ~S"""
    `input` is a version string. Return a boolean: whether it satisfies the version requirement "~> 2.0".
    """,
    solution: ~S|Version.match?(input, "~> 2.0")|,
    checks: [
      {~S|"2.1.0"|, ~S|true|},
      {~S|"3.0.0"|, ~S|false|},
      {~S|"2.0.0"|, ~S|true|}
    ],
    tags: [:version],
    difficulty: :medium
  },
  %{
    id: "runtime/function-exported",
    prompt: ~S"""
    `input` is a `{module, function_name, arity}` tuple where the module is already loaded. Return a boolean: whether that module exports a function with that name and arity.
    """,
    solution: ~S"""
    {m, f, a} = input
    function_exported?(m, f, a)
    """,
    checks: [
      {~S|{Enum, :map, 2}|, ~S|true|},
      {~S|{Enum, :map, 5}|, ~S|false|},
      {~S|{String, :upcase, 1}|, ~S|true|}
    ],
    tags: [:code],
    difficulty: :medium
  }
]
