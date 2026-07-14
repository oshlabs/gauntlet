# Gauntlet

A repeatable benchmark of LLM capability at **Elixir** — itself written in
Elixir.

Public coding benchmarks barely cover Elixir (MultiPL-E and Aider's polyglot
benchmark skip it entirely), and models that ace Python katas routinely
stumble over OTP, laziness, macros, and protocols. Gauntlet measures that
gap with tasks that are **graded by execution, never by judgment**: model
answers are compiled and run against hidden ExUnit suites in a throwaway
sandbox project, in a separate OS process, with hard timeouts.

Any OpenAI-compatible endpoint works (local vLLM/llama.cpp/Ollama, cloud
APIs); runs are stored with enough metadata that two runs of the same suite
are directly comparable across models and across time.

---

## How it works

For every `(model, task, sample)`:

```
prompt.md ──► LLM ──► extract last ```elixir block
                            │
                            ▼
              copy pre-warmed sandbox project
              write code as lib/solution.ex
              copy hidden checks/ into test/
                            │
                            ▼
              mix test  (separate OS process,
              JSON per-test results, process-group
              kill at task timeout)
                            │
                            ▼
              verdict ──► verdicts.jsonl ──► scores
```

If the run has `--repair` enabled and round 1 failed, the failing test
output is fed back to the model in the same conversation for exactly one
more attempt (the [Aider](https://aider.chat) protocol). Repair success is
scored separately — writing code right the first time and fixing code from
a failure report are different skills.

Comprehension tasks (predict-output, multiple choice) skip the sandbox and
are graded by exact comparison against a recorded expectation — which is
itself verified by *executing the program* at validation time.

Two safety properties hold throughout:

- **Generated code never runs inside the harness BEAM.** Compilation and
  tests happen in a separate OS process; on timeout the whole process group
  is killed.
- **The harness never trusts its own task pack.** `mix gauntlet.validate`
  pushes every task's reference solution through the identical pipeline and
  demands a pass — CI for the benchmark content, no LLM involved.

---

## Setup

Requirements: Erlang/OTP 28, Elixir ~> 1.19 (pinned in `.tool-versions`),
and a reachable OpenAI-compatible endpoint.

```console
$ mix deps.get
$ mix test                 # harness self-test, no LLM needed
$ mix gauntlet.validate    # task-pack CI, no LLM needed
```

### Registering a model

Models live in [`models.exs`](models.exs) at the repo root:

```elixir
%{
  "deepseek-v4-flash" => %{
    model_spec: "openai:deepseek-v4-flash",     # provider:id for req_llm
    base_url: "http://172.31.0.100:8000/v1",    # any OpenAI-compatible endpoint
    api_key_env: "GAUNTLET_API_KEY",            # env var; falls back to...
    api_key_default: "unused",                  # ...this (local servers don't care)
    max_concurrency: 8,     # match the server's useful parallelism
    max_tokens: 32_768,     # generous headroom for reasoning models
    temperature: 0.0,
    reasoning: %{expected: true},
    request_timeout_ms: 1_800_000
  }
}
```

Adding a model = adding an entry. A hosted provider looks like
`model_spec: "anthropic:claude-sonnet-5"` with no `base_url` and a real
`api_key_env` — req_llm handles the provider differences. Set
`max_concurrency` to what the endpoint can actually serve in parallel
(e.g. vLLM's `--max-num-seqs`); more just queues server-side and skews
latency numbers.

Reasoning models are handled transparently: the answer is read from the
message content, while reasoning output (`reasoning`/`reasoning_content`
fields) is recorded in the run log but never parsed for code.

---

## Running

```console
# the full default suite
$ mix gauntlet.run --model deepseek-v4-flash

# recommended: with the repair round
$ mix gauntlet.run --model deepseek-v4-flash --suite core --repair

# one task, quick probe
$ mix gauntlet.run --model deepseek-v4-flash --only frequency_map

# multiple samples per task (enables pass@k thinking; costs linearly)
$ mix gauntlet.run --model deepseek-v4-flash --samples 3

# include each task's context.md in the prompt (the context-injection experiment)
$ mix gauntlet.run --model deepseek-v4-flash --context
```

Discovery:

```console
$ mix gauntlet.list            # suites, tasks, weights, suite hash
$ mix gauntlet.list --models   # registered models
```

While a run is in flight it prints one line per graded attempt:

```
core/frequency_map s1 r1: fail
core/frequency_map s1 r2: pass
core/genserver_kv_ttl s1 r1: pass
```

(`s` = sample, `r` = round; round 2 is the repair attempt.)

---

## Reading the results

Every run creates a directory under `runs/`:

```
runs/2026-07-14T113523Z_deepseek-v4-flash_core/
├── meta.json        # model params, suite name+hash, harness git sha,
│                    # prompt template versions, flags, toolchain
├── events.jsonl     # one line per LLM request/response: full prompt,
│                    # content, reasoning, token usage, latency
├── verdicts.jsonl   # one line per graded attempt — the stable interface
├── summary.json     # the aggregate scores, machine-readable
├── report.md        # the human-readable version of summary.json
└── attempts/        # sandbox dirs of FAILING attempts (passes are pruned)
```

### A real report

From the first DeepSeek V4 Flash run of the `core` suite:

```markdown
## Dimensions

| group         | attempts | pass@1 | pass@repair | repair rate |
|---------------|----------|--------|-------------|-------------|
| comprehension | 1        | 0.0%   | 0.0%        | —           |
| generation    | 10       | 33.3%  | 57.6%       | 50.0%       |

## Outcome counts

- pass: 6
- fail: 5
- compile_error: 5
- timeout: 1

## Composite

**0.212** (weighted pass@1; only comparable at identical suite hash)
```

### The metrics

- **pass@1** — weighted fraction of tasks whose *first* attempt passed
  every hidden test. The headline "can it write correct Elixir cold"
  number. Weighted: hard curated tasks count more than easy ones
  (`weight:` in each task's metadata).
- **pass@repair** — passed within two rounds. The "useful with a test
  loop" number; this is what an agentic coding setup would experience.
- **repair rate** — of the round-1 failures that got a repair attempt, how
  many round 2 rescued. Isolates self-correction skill from
  first-shot skill. Note it can be *worse* than doing nothing — in the run
  above, one repair attempt regressed a partial solution (2/8 tests → 0/8).
- **composite** — the per-dimension pass@1 scores folded through the
  suite's weight table. Deliberately printed last: read the dimension
  table first, and never compare composites across different suite hashes
  (the report refuses to, and so should you).

### The verdict statuses

Every attempt lands on exactly one status. They are ordered here from "the
model did fine" to "something else went wrong" — the middle ones are the
informative failures:

| status | meaning | how to read it |
|---|---|---|
| `pass` | every hidden test passed | correct (to the extent the tests pin it down) |
| `fail` | compiled, but ≥1 test failed | wrong or incomplete logic; `tests` shows how close (7/8 is a near miss, 0/8 usually means it solved a different problem) |
| `compile_error` | test suite never ran | invalid syntax, hallucinated APIs, or the answer ignored a structural instruction (wrong module/struct name) the tests compile against |
| `timeout` | killed at the task's deadline | usually an eager/blocking implementation where laziness or concurrency was the point — a *semantic* failure caught by execution |
| `truncated` | response hit max_tokens | not graded further; raise `max_tokens` for the model or task |
| `extraction_failed` | no ```elixir block found | the model didn't follow the answer format; scored as a real failure (format-following is part of the job) |
| `llm_error` | endpoint error after retries | infrastructure, not the model — investigate before comparing runs |

`fail` and `compile_error` verdicts keep their sandbox directory under
`attempts/` and carry the failing test output in the verdict's `detail`
field, so you can always reconstruct *why*. To dig into what the model
actually said, grep `events.jsonl` — it holds the full conversation
including reasoning output and exact token counts.

### Tiers: curated vs knowledge vs smoke

Scores are always split by tier before any aggregate. **curated** tasks are
hand-written for this benchmark and target known model weak zones (OTP
lifecycle, supervision, Registry, laziness, binaries, protocols, macros,
Unicode). **knowledge** is the micro pack (see below) — 500 tiny language
probes; its score reads as "how much of the Elixir surface does this model
actually know", with error bars small enough to rank models. **smoke**
tasks (planned M2: an Exercism import) are public problems that models
have almost certainly trained on — they verify a model is minimally
competent and that the plumbing works, but a high smoke score is *not*
evidence of Elixir skill. Distrust any summary of this benchmark that
quotes a blended number.

### Comparing models

Run the same suite against another model, then compare the two run
directories. `meta.json` carries a `suite.hash` — a sha256 over the entire
task-pack content. Same hash ⇒ the numbers are apples-to-apples; different
hash ⇒ tasks changed and only per-task inspection is meaningful. (An
automated side-by-side `mix gauntlet.report runs/A runs/B` is the M2
milestone.)

Latency and token counts in the report describe *cost*, not quality — a
model that thinks for 3 minutes per task and scores 60% is a different tool
from one that answers in 10 seconds and scores 50%. Both facts are in
`summary.json`.

---

## Anatomy of a task

Tasks are directories under `priv/tasks/<pack>/<id>/`:

```
genserver_kv_ttl/
├── task.exs        # metadata (see below)
├── prompt.md       # the spec shown to the model
├── stub.ex         # optional starting code (shown)
├── context.md      # optional docs, injected only with --context
├── solution.ex     # reference solution (never shown; used by validate)
├── buggy.ex        # debugging tasks: the code to fix (shown)
├── expected.txt    # predict-output tasks: the exact expected stdout
└── checks/         # hidden ExUnit tests (never shown)
    └── solution_test.exs
```

```elixir
# task.exs
%{
  id: "core/genserver_kv_ttl",
  dimension: :generation,   # :generation | :comprehension | :debugging | :quality
  type: :write_code,        # :write_code | :fix_code | :predict_output | :mcq
  difficulty: :hard,        # :smoke | :easy | :medium | :hard
  tags: [:curated, :otp, :genserver],
  module_name: "TtlStore",  # module the model must define
  timeout_ms: 90_000,       # sandbox budget (compile + tests)
  weight: 2.0               # weight in the scores (smoke tier uses 0.5)
}
```

### Writing a good task

1. The prompt must fully specify observable behaviour — the model can't see
   the tests, so anything graded must be stated (or be a reasonable reading
   of what's stated).
2. Tests should probe *behaviour that distinguishes real understanding*:
   kill the worker and assert the supervisor restarts it; feed an infinite
   stream so eagerness hangs; check `__info__(:functions)` so a macro must
   actually generate functions. The BEAM lets tests assert things most
   benchmarks can't — use that.
3. Write `solution.ex` and run `mix gauntlet.validate --only <id>`. If your
   own solution can't pass your own tests under the real pipeline, the task
   is broken, not the models.
4. Suites and weights live in `priv/tasks/suites.exs`. Remember: editing a
   task changes the suite hash and honestly breaks comparability with older
   runs — that's the feature working.

---

## The micro pack (`micro`, 500 knowledge items)

Where the core pack asks "can you build this component", the micro pack
asks five hundred variants of "do you actually know the language": *`input`
is the string "foobar" — return its first three letters*. The model
answers with a **single expression**, which is spliced into a wrapper
module and graded by generated ExUnit tests — same execution-based
grading, near-zero boilerplate:

```elixir
defmodule Micro do
  def solve(input) do
    _ = input
    __SNIPPET__        # <- the model's expression
  end
end
```

Items are data, not directories — themed files in `priv/tasks/micro/`
(`enum.exs`, `string.exs`, `collections.exs`, `kernel.exs`, `numbers.exs`,
`datetime_access.exs`, `runtime.exs`, `utilities.exs`), each a list of
maps:

```elixir
%{
  id: "enum/double",
  prompt: ~S{`input` is a list of numbers. Return a list with every value doubled.},
  solution: ~S{Enum.map(input, &(&1 * 2))},
  checks: [{~S{[1, 2, 3]}, ~S{[2, 4, 6]}}, {~S{[]}, ~S{[]}}],
  tags: [:enum],
  difficulty: :easy
}
```

Because a wrong micro-item is self-diagnosing, the per-tag breakdown in
`verdicts.jsonl` reads like a skills report card: strings vs OTP vs dates
vs binaries. Three item flavors deserve mention:

- **traps** (`:trap`) — the prompt's tempting answer is a function that
  does not exist or was removed (`String.strip`, a nonexistent
  `Enum.compact`); only the real API passes. Measures the hallucinated-
  stdlib failure mode directly. Every trap was verified against the
  pinned Elixir before authoring.
- **drift** (`:drift`) — the idiomatic answer changed recently (built-in
  `JSON` since 1.18, `Duration`/`Date.shift` since 1.17, descending-range
  `10..1//-1`, `~c""` charlists). Distinguishes fresh from stale training
  data.
- **gotchas** (`:gotcha`) — semantics people (and models) get wrong:
  `rem(-5, 3)`, `String.length` vs `byte_size`, struct comparison with
  `<`, truthiness of `0`.

Authoring more items: see `priv/tasks/micro/AUTHORING.md`; the fast
iteration loop is `elixir priv/tasks/check_items.exs <file>` and the
authoritative gate stays `mix gauntlet.validate --suite micro`.

Run only this pack with `mix gauntlet.run --model <m> --suite micro`.
Repair rounds apply to snippets too, and extraction is deliberately
lenient (a bare single-line reply counts) — the pack measures language
knowledge, not fence discipline.

## Current task pack (`core`, 11 tasks)

| task | difficulty | targets |
|---|---|---|
| frequency_map | easy | strings, Unicode-aware regex |
| config_validator | easy | `with` pipelines, error tuples, instruction-following |
| binary_frame_parser | medium | binary pattern matching |
| lazy_chunker | medium | Streams — the tests hang eager implementations |
| parallel_map | medium | Task concurrency, timeout isolation, mailbox hygiene |
| genserver_kv_ttl | hard | GenServer, timer lifecycle, stale-message races |
| supervised_worker | hard | real supervision: kill → restart, sibling isolation |
| counter_registry | hard | Registry + DynamicSupervisor, start-race handling |
| enumerable_bitset | hard | Enumerable protocol: real count/member?/halting |
| deftags_macro | hard | macro hygiene, compile-time codegen |
| predict_gotchas | medium | comprehension: charlists, div/rem, exceptions… |

## Roadmap

- **M2** — Exercism import (smoke tier), `mix gauntlet.report A B`
  cross-run comparison.
- **M3** — debugging dimension (`:fix_code` with recorded failure output),
  more comprehension tasks.
- **M4** — quality graders on passing solutions (compiler warnings, credo,
  format-diff, optional pinned LLM judge as a separate score), behavioral
  runtime probes as a distinct grader, context-injection experiments.

## License

MIT — see [LICENSE](LICENSE). Task-pack content (prompts, checks, reference
solutions) is covered by the same license; if you add an imported pack
(e.g. Exercism-derived), keep its upstream license file alongside it.

## Trust model

The sandbox is *process-level* isolation: separate OS process, no deps,
hard timeout, process-group kill. That is honest containment for benchmarking
models you chose to run, not a security boundary against adversarial code —
generated code could still touch the filesystem or network during a test
run. If you ever benchmark untrusted models, wrap runs in a container.

Two deliberate policies keep the practical exposure small:

- **Task content is audited to be side-effect-free.** No task, check, or
  reference solution touches the filesystem, shell, network, environment,
  ports, or distribution (grep-audited across all packs; the authoring
  rules in `priv/tasks/micro/AUTHORING.md` ban these outright, partly for
  determinism, partly for safety). The only I/O in a benchmark run is the
  harness's own run-directory writes.
- **Prompts never invite side effects.** Every task asks for a pure
  computation over an in-memory value. A benign model answering "return
  the first three letters of this string" has no reason to emit file
  operations — so uncontained execution is a calculated risk taken for
  models you deliberately installed, not an oversight. The moment you
  benchmark a model you *don't* trust (a random community fine-tune),
  that reasoning no longer holds: use a container.
