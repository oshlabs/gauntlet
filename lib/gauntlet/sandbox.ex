defmodule Gauntlet.Sandbox do
  @moduledoc """
  Materializes a model's solution into a throwaway copy of the sandbox
  template and runs `mix test` there as a separate OS process.

  Generated code is never evaluated inside the harness BEAM. The child is
  started through `setsid` so it leads its own process group; on timeout the
  whole group is killed. Output is capped at 256 KB.
  """

  alias Gauntlet.Task

  @output_cap 256 * 1024
  @results_file "gauntlet_results.jsonl"

  @type test_result :: %{
          status: :pass | :fail | :compile_error | :timeout,
          tests: %{total: non_neg_integer(), passed: non_neg_integer()},
          failures: [map()],
          output: String.t(),
          exit_status: integer() | nil
        }

  @doc """
  Copy the warmed template to `attempt_dir` and install the solution
  (as `lib/solution.ex`) plus the task's hidden check files (into `test/`).

  For `:snippet` tasks, `code` is the bare expression and is spliced into
  the task's wrapper module first.
  """
  @spec materialize(String.t(), Task.t(), String.t(), String.t()) :: :ok
  def materialize(template_dir, %Task{} = task, code, attempt_dir) do
    code =
      case task.type do
        :snippet -> Task.splice_snippet(task.wrapper, code)
        _ -> code
      end

    File.mkdir_p!(attempt_dir)
    File.cp_r!(template_dir, attempt_dir)
    File.write!(Path.join(attempt_dir, "lib/solution.ex"), code)

    for {name, contents} <- task.check_files do
      File.write!(Path.join([attempt_dir, "test", as_test_file(name)]), contents)
    end

    :ok
  end

  @doc """
  Run `mix test` in `attempt_dir` with a hard timeout (kills the whole
  process group). Parses the JSON results file written by the sandbox's
  formatter; falls back to the exit status when compilation failed before
  any test could run.
  """
  @spec run_tests(String.t(), keyword()) :: test_result()
  def run_tests(attempt_dir, opts \\ []) do
    timeout = Keyword.get(opts, :timeout_ms, 60_000)
    # Absolute: the child runs with cwd = attempt_dir, and a relative path
    # would silently point the formatter at a non-existent subtree.
    results_path = Path.expand(Path.join(attempt_dir, @results_file))

    # No setsid: the port child is already a process-group leader (verified —
    # its pgid equals its pid), so the timeout kill of -os_pid reaches the
    # whole tree. setsid would fork, making exit_status the parent's 0.
    port =
      Port.open({:spawn_executable, System.find_executable("sh")}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        :hide,
        {:args, ["-c", "exec mix test --seed 0 --max-failures 20"]},
        {:cd, attempt_dir},
        {:env,
         [
           {~c"MIX_ENV", ~c"test"},
           {~c"GAUNTLET_RESULTS_FILE", String.to_charlist(results_path)}
         ]}
      ])

    os_pid = port |> Port.info() |> Keyword.get(:os_pid)
    deadline = System.monotonic_time(:millisecond) + timeout

    case collect(port, os_pid, deadline, [], 0) do
      {:exit, status, output} -> interpret(results_path, status, output)
      {:timeout, output} -> timeout_result(output)
    end
  end

  defp collect(port, os_pid, deadline, acc, size) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    receive do
      {^port, {:data, data}} ->
        {acc, size} =
          if size < @output_cap do
            {[acc | data], size + byte_size(data)}
          else
            {acc, size}
          end

        collect(port, os_pid, deadline, acc, size)

      {^port, {:exit_status, status}} ->
        {:exit, status, IO.iodata_to_binary(acc)}
    after
      remaining ->
        kill_process_group(os_pid)
        flush_port(port)
        {:timeout, IO.iodata_to_binary(acc)}
    end
  end

  defp kill_process_group(nil), do: :ok

  defp kill_process_group(os_pid) do
    System.cmd("kill", ["-KILL", "-#{os_pid}"], stderr_to_stdout: true)
    :ok
  end

  # After killing the group the port still delivers pending data + exit_status.
  defp flush_port(port) do
    receive do
      {^port, {:exit_status, _}} ->
        :ok

      {^port, {:data, _}} ->
        flush_port(port)
    after
      5_000 ->
        if Port.info(port), do: Port.close(port)
        :ok
    end
  end

  defp interpret(results_path, exit_status, output) do
    case parse_results(results_path) do
      {:ok, tests, summary} ->
        passed = summary[:passed] || Enum.count(tests, &(&1.state == "passed"))
        failed = summary[:failed] || Enum.count(tests, &(&1.state == "failed"))
        invalid = summary[:invalid] || 0
        total = length(tests)

        status =
          if failed + invalid == 0 and exit_status == 0 and total > 0,
            do: :pass,
            else: :fail

        %{
          status: status,
          tests: %{total: total, passed: passed},
          failures: Enum.filter(tests, &(&1.state != "passed")),
          output: output,
          exit_status: exit_status
        }

      :error ->
        # No structured results: mix test never reached the suite (compile
        # error, missing module, crash during load).
        %{
          status: :compile_error,
          tests: %{total: 0, passed: 0},
          failures: [],
          output: output,
          exit_status: exit_status
        }
    end
  end

  defp timeout_result(output) do
    %{
      status: :timeout,
      tests: %{total: 0, passed: 0},
      failures: [],
      output: output,
      exit_status: nil
    }
  end

  # Check files are installed as ExUnit test files; normalize names so
  # `mix test` picks them up regardless of what the task dir calls them.
  defp as_test_file(name) do
    if String.ends_with?(name, "_test.exs") do
      name
    else
      String.replace_suffix(name, ".exs", "_test.exs")
    end
  end

  defp parse_results(path) do
    with true <- File.regular?(path),
         {:ok, contents} when contents != "" <- File.read(path) do
      lines =
        contents
        |> String.split("\n", trim: true)
        |> Enum.map(&Jason.decode!(&1, keys: :atoms))

      tests = Enum.filter(lines, &(&1.event == "test_finished"))
      summary = Enum.find(lines, %{}, &(&1.event == "suite_finished"))
      {:ok, tests, summary}
    else
      _ -> :error
    end
  end
end
