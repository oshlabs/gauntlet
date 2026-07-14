defmodule Gauntlet.SandboxTest do
  use ExUnit.Case, async: false

  alias Gauntlet.{Sandbox, Suite}
  alias Gauntlet.Task, as: BenchTask

  @moduletag timeout: 180_000

  setup_all do
    work_dir =
      Path.join(System.tmp_dir!(), "gauntlet_sandbox_test_#{System.os_time(:millisecond)}")

    File.mkdir_p!(work_dir)
    {:ok, template} = Sandbox.Template.prepare(work_dir)
    on_exit(fn -> File.rm_rf!(work_dir) end)
    %{template: template, work_dir: work_dir}
  end

  setup %{work_dir: work_dir} do
    attempt_dir = Path.join([work_dir, "attempts", "t#{System.unique_integer([:positive])}"])
    %{attempt_dir: attempt_dir}
  end

  defp adder_task do
    {:ok, suite} = Suite.load("mini", tasks_dir: "test/fixtures/tasks")
    Enum.find(suite.tasks, &(&1.id == "mini/adder"))
  end

  test "correct solution passes", %{template: template, attempt_dir: dir} do
    task = adder_task()

    Sandbox.materialize(
      template,
      task,
      "defmodule Adder do\n  def add(a, b), do: a + b\nend\n",
      dir
    )

    result = Sandbox.run_tests(dir, timeout_ms: 60_000)

    assert result.status == :pass
    assert result.tests == %{total: 1, passed: 1}
  end

  test "wrong solution fails with failure detail", %{template: template, attempt_dir: dir} do
    task = adder_task()

    Sandbox.materialize(
      template,
      task,
      "defmodule Adder do\n  def add(a, b), do: a - b\nend\n",
      dir
    )

    result = Sandbox.run_tests(dir, timeout_ms: 60_000)

    assert result.status == :fail
    assert result.tests.passed == 0
    assert [%{failure: failure} | _] = result.failures
    assert failure =~ "Assertion"
  end

  test "code that does not compile is a compile_error", %{template: template, attempt_dir: dir} do
    task = adder_task()
    Sandbox.materialize(template, task, "defmodule Adder do\n  this is not elixir\nend\n", dir)
    result = Sandbox.run_tests(dir, timeout_ms: 60_000)

    assert result.status == :compile_error
    assert result.output =~ "error"
  end

  test "missing module is not a pass", %{template: template, attempt_dir: dir} do
    task = adder_task()
    Sandbox.materialize(template, task, "defmodule Wrong do\nend\n", dir)
    result = Sandbox.run_tests(dir, timeout_ms: 60_000)

    assert result.status in [:fail, :compile_error]
  end

  test "hanging solution is killed at timeout with its process group", %{
    template: template,
    attempt_dir: dir
  } do
    task = adder_task()

    # hangs at module load time (test compilation), before any test runs
    code = """
    defmodule Adder do
      def add(a, b), do: a + b
    end

    Process.sleep(:infinity)
    """

    Sandbox.materialize(template, task, code, dir)

    started = System.monotonic_time(:millisecond)
    result = Sandbox.run_tests(dir, timeout_ms: 3_000)
    elapsed = System.monotonic_time(:millisecond) - started

    assert result.status == :timeout
    # killed near the deadline, not after some longer internal timeout
    assert elapsed < 15_000

    # no beam.smp survivors running from this attempt dir
    {ps, 0} = System.cmd("ps", ["-eo", "pid,args"], stderr_to_stdout: true)
    refute ps =~ dir
  end
end
