defmodule GauntletJsonFormatter do
  @moduledoc """
  ExUnit formatter writing one JSON line per finished test to the file named
  by the GAUNTLET_RESULTS_FILE env var, plus a final suite summary line.
  Runs alongside the CLI formatter; must not depend on anything outside the
  standard library (the sandbox project is dependency-free).
  """

  use GenServer

  def init(_opts) do
    path = System.fetch_env!("GAUNTLET_RESULTS_FILE")
    {:ok, io} = File.open(path, [:write, :utf8])
    {:ok, %{io: io, passed: 0, failed: 0, skipped: 0, invalid: 0}}
  end

  def handle_cast({:test_finished, %ExUnit.Test{} = test}, state) do
    {state_key, state_name, failure} =
      case test.state do
        nil -> {:passed, "passed", nil}
        {:failed, failures} -> {:failed, "failed", format_failures(test, failures)}
        {:skipped, reason} -> {:skipped, "skipped", to_string(reason)}
        {:excluded, _} -> {:skipped, "excluded", nil}
        {:invalid, _} -> {:invalid, "invalid", "test module failed to set up"}
      end

    line =
      JSON.encode!(%{
        event: "test_finished",
        name: to_string(test.name),
        module: inspect(test.module),
        state: state_name,
        time_us: test.time,
        failure: failure
      })

    IO.puts(state.io, line)
    {:noreply, Map.update!(state, state_key, &(&1 + 1))}
  end

  def handle_cast({:suite_finished, _times}, state) do
    line =
      JSON.encode!(%{
        event: "suite_finished",
        passed: state.passed,
        failed: state.failed,
        skipped: state.skipped,
        invalid: state.invalid
      })

    IO.puts(state.io, line)
    File.close(state.io)
    {:noreply, state}
  end

  def handle_cast(_event, state), do: {:noreply, state}

  defp format_failures(test, failures) do
    failures
    |> Enum.map_join("\n---\n", fn {kind, reason, stacktrace} ->
      Exception.format(kind, reason, prune_stacktrace(test, stacktrace))
    end)
    |> truncate(4_096)
  end

  # Keep only frames from the test file itself; full traces are noise.
  defp prune_stacktrace(%ExUnit.Test{tags: %{file: file}}, stacktrace) do
    Enum.filter(stacktrace, fn
      {_m, _f, _a, meta} -> to_string(meta[:file] || "") =~ Path.basename(file)
      _ -> false
    end)
  end

  defp prune_stacktrace(_test, stacktrace), do: stacktrace

  defp truncate(s, max) when byte_size(s) > max, do: binary_part(s, 0, max) <> "…[truncated]"
  defp truncate(s, _max), do: s
end
