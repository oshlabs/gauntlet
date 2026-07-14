defmodule Gauntlet.Runner do
  @moduledoc """
  Orchestrates a benchmark run: for every (task, sample) it builds the
  prompt, calls the model, extracts the answer, grades it (via the sandbox
  for code tasks), optionally runs one Aider-style repair round, and appends
  events + verdicts to the run store.

  Two independent semaphores bound the work: `:llm` slots (the endpoint's
  useful concurrency) and `:eval` slots (local `mix test` runs are
  multi-core). LLM waiting overlaps local compiles naturally because each
  attempt acquires slots only around the step that needs them.
  """

  require Logger

  alias Gauntlet.{Extract, Graders, Limiter, Model, Prompt, Report, Sandbox, Score, Store, Suite}
  alias Gauntlet.Task, as: BenchTask
  alias Gauntlet.Verdict

  @llm_retries 2
  @failure_excerpt_bytes 6_144

  @doc """
  Run a suite against a model. Returns `{:ok, %{summary: map, run_dir: path}}`.

  Options:
    * `:samples` - samples per task (default 1)
    * `:repair` - run one repair round on failing code tasks (default false)
    * `:context_injection` - include task context.md in prompts (default false)
    * `:runs_dir` - where run directories are created (default "runs")
    * `:progress` - fun called with progress strings (default logs)
  """
  @spec run(Model.t(), Suite.t(), keyword()) :: {:ok, map()}
  def run(%Model{} = model, %Suite{} = suite, opts \\ []) do
    model = Model.with_overrides(model, opts)
    samples = Keyword.get(opts, :samples, 1)
    store = Store.create(model.name, suite.name, meta(model, suite, opts), opts)

    {:ok, template} = Sandbox.Template.prepare(Store.work_dir(store))
    {:ok, llm} = Limiter.start_link(count: model.max_concurrency)
    {:ok, eval} = Limiter.start_link(count: eval_slots())

    ctx = %{
      model: model,
      store: store,
      template: template,
      llm: llm,
      eval: eval,
      opts: opts,
      progress: Keyword.get(opts, :progress, &Logger.info/1)
    }

    attempts = for task <- suite.tasks, sample <- 1..samples, do: {task, sample}

    verdicts =
      attempts
      |> Task.async_stream(fn {task, sample} -> run_attempt(ctx, task, sample) end,
        max_concurrency: model.max_concurrency * 2,
        ordered: false,
        timeout: :infinity
      )
      |> Enum.flat_map(fn {:ok, verdicts} -> verdicts end)

    summary = Score.summarize(verdicts, suite)
    Store.write_summary(store, summary)

    Store.write_report(
      store,
      Report.render(summary, Map.put(meta(model, suite, opts), :run_id, Path.basename(store.dir)))
    )

    Store.prune_attempts(store, verdicts)

    {:ok, %{summary: summary, run_dir: store.dir, verdicts: verdicts}}
  end

  @doc false
  def run_attempt(ctx, %BenchTask{} = task, sample) do
    built = Prompt.build(task, ctx.opts)

    case complete(ctx, task, built.messages, sample, 1) do
      {:ok, result} ->
        verdict = grade(ctx, task, sample, 1, result)
        Store.append_verdict(ctx.store, verdict)
        ctx.progress.("#{task.id} s#{sample} r1: #{verdict.status}")

        case maybe_repair(ctx, task, sample, built.messages, result, verdict) do
          nil -> [verdict]
          repair_verdict -> [verdict, repair_verdict]
        end

      {:error, reason} ->
        verdict = error_verdict(ctx, task, sample, 1, reason)
        Store.append_verdict(ctx.store, verdict)
        ctx.progress.("#{task.id} s#{sample} r1: llm_error")
        [verdict]
    end
  end

  # -- LLM call ---------------------------------------------------------------

  defp complete(ctx, task, messages, sample, round, retries \\ @llm_retries) do
    model = ctx.model
    adapter = model.adapter

    result =
      Limiter.with_slot(ctx.llm, fn ->
        adapter.complete(model, messages, max_tokens: task.max_tokens || model.max_tokens)
      end)

    case result do
      {:ok, response} ->
        Store.append_event(ctx.store, %{
          task_id: task.id,
          sample: sample,
          round: round,
          messages: messages,
          content: response.content,
          thinking_bytes: byte_size(response.thinking || ""),
          thinking: response.thinking,
          usage: response.usage,
          finish_reason: response.finish_reason,
          latency_ms: response.latency_ms
        })

        {:ok, response}

      {:error, reason} when retries > 0 ->
        Logger.warning("#{task.id}: llm error #{inspect(reason)}, retrying")
        Process.sleep((@llm_retries - retries + 1) * 2_000)
        complete(ctx, task, messages, sample, round, retries - 1)

      {:error, reason} ->
        Store.append_event(ctx.store, %{
          task_id: task.id,
          sample: sample,
          round: round,
          error: inspect(reason)
        })

        {:error, reason}
    end
  end

  # -- Grading ----------------------------------------------------------------

  defp grade(ctx, task, sample, round, result) do
    base = base_verdict(ctx, task, sample, round, result)

    cond do
      truncated?(result) ->
        %{base | status: :truncated}

      task.type in [:predict_output, :mcq] ->
        graded = Graders.Comprehension.grade(task, %{content: result.content})
        %{base | status: graded.status, subscores: graded.subscores}

      true ->
        grade_code(ctx, task, base, result)
    end
  end

  defp grade_code(ctx, task, base, result) do
    extracted =
      case task.type do
        :snippet -> Extract.snippet(result.content)
        _ -> Extract.code_block(result.content)
      end

    case extracted do
      nil ->
        %{base | status: :extraction_failed}

      code ->
        attempt_dir = Store.attempt_dir(ctx.store, task.id, base.sample, base.round)

        sandbox_result =
          Limiter.with_slot(ctx.eval, fn ->
            Sandbox.materialize(ctx.template, task, code, attempt_dir)
            Sandbox.run_tests(attempt_dir, timeout_ms: task.timeout_ms)
          end)

        graded = Graders.ExUnit.grade(task, %{sandbox: sandbox_result})

        %{
          base
          | status: graded.status,
            tests: graded.tests,
            subscores: graded.subscores,
            detail: failure_excerpt(sandbox_result)
        }
    end
  end

  defp base_verdict(ctx, task, sample, round, result) do
    %Verdict{
      task_id: task.id,
      model: ctx.model.name,
      sample: sample,
      round: round,
      status: :fail,
      dimension: task.dimension,
      difficulty: task.difficulty,
      weight: task.weight,
      usage: result.usage,
      latency_ms: result.latency_ms
    }
  end

  defp error_verdict(ctx, task, sample, round, reason) do
    %Verdict{
      task_id: task.id,
      model: ctx.model.name,
      sample: sample,
      round: round,
      status: :llm_error,
      dimension: task.dimension,
      difficulty: task.difficulty,
      weight: task.weight,
      detail: inspect(reason)
    }
  end

  defp truncated?(%{finish_reason: reason}) do
    reason in [:length, "length", :max_tokens, "max_tokens"]
  end

  # -- Repair round -----------------------------------------------------------

  defp maybe_repair(ctx, task, sample, messages, result, %Verdict{} = round1) do
    repair? =
      Keyword.get(ctx.opts, :repair, false) and
        BenchTask.needs_sandbox?(task) and
        round1.status in [:fail, :compile_error, :extraction_failed]

    if repair? do
      followup =
        messages ++
          [
            %{role: :assistant, content: result.content},
            Prompt.repair_message(task, round1.detail || "The tests failed.")
          ]

      verdict =
        case complete(ctx, task, followup, sample, 2) do
          {:ok, repair_result} -> grade(ctx, task, sample, 2, repair_result)
          {:error, reason} -> error_verdict(ctx, task, sample, 2, reason)
        end

      Store.append_verdict(ctx.store, verdict)
      ctx.progress.("#{task.id} s#{sample} r2: #{verdict.status}")
      verdict
    end
  end

  defp failure_excerpt(%{status: :pass}), do: nil

  defp failure_excerpt(%{failures: failures, output: output}) do
    text =
      case failures do
        [] -> output
        _ -> Enum.map_join(failures, "\n", &(&1[:failure] || &1[:name] || ""))
      end

    tail(text, @failure_excerpt_bytes)
  end

  defp tail(text, max) when byte_size(text) > max do
    "…" <> binary_part(text, byte_size(text) - max, max)
  end

  defp tail(text, _max), do: text

  # -- Meta -------------------------------------------------------------------

  defp eval_slots do
    max(min(div(System.schedulers_online(), 2), 4), 1)
  end

  defp meta(model, suite, opts) do
    %{
      run_id: nil,
      model: %{
        id: model.name,
        spec: model.model_spec,
        base_url: model.base_url,
        temperature: model.temperature,
        reasoning_effort: model.reasoning_effort,
        max_tokens: model.max_tokens
      },
      suite: %{name: suite.name, hash: suite.hash, task_count: length(suite.tasks)},
      harness: %{git_sha: git_sha(), prompt_versions: Prompt.versions()},
      flags: %{
        repair: Keyword.get(opts, :repair, false),
        context_injection: Keyword.get(opts, :context_injection, false),
        samples: Keyword.get(opts, :samples, 1)
      },
      toolchain: %{elixir: System.version(), otp: System.otp_release()}
    }
  end

  defp git_sha do
    case System.cmd("git", ["rev-parse", "HEAD"], stderr_to_stdout: true) do
      {sha, 0} -> String.trim(sha)
      _ -> nil
    end
  end
end
