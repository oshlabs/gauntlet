defmodule WatchdogTest do
  use ExUnit.Case

  setup do
    sup = start_supervised!(Watchdog)
    %{sup: sup}
  end

  defp wait_registered(name, tries \\ 100)
  defp wait_registered(_name, 0), do: flunk("worker never re-registered")

  defp wait_registered(name, tries) do
    case Process.whereis(name) do
      nil ->
        Process.sleep(10)
        wait_registered(name, tries - 1)

      pid ->
        pid
    end
  end

  test "workers start registered with zero counters" do
    assert Watchdog.Worker.value(:wd_alpha) == 0
    assert Watchdog.Worker.value(:wd_beta) == 0
  end

  test "increment is per worker" do
    assert Watchdog.Worker.increment(:wd_alpha) == 1
    assert Watchdog.Worker.increment(:wd_alpha) == 2
    assert Watchdog.Worker.value(:wd_beta) == 0
  end

  test "a crashed worker is restarted by the supervisor" do
    pid = Process.whereis(:wd_alpha)
    ref = Process.monitor(pid)

    Watchdog.Worker.crash(:wd_alpha)
    assert_receive {:DOWN, ^ref, :process, ^pid, reason} when reason != :normal, 1_000

    new_pid = wait_registered(:wd_alpha)
    assert new_pid != pid
    assert Watchdog.Worker.value(:wd_alpha) == 0
  end

  test "crash of one worker leaves the sibling's state intact" do
    Watchdog.Worker.increment(:wd_beta)
    Watchdog.Worker.increment(:wd_beta)
    beta_pid = Process.whereis(:wd_beta)

    pid = Process.whereis(:wd_alpha)
    ref = Process.monitor(pid)
    Watchdog.Worker.crash(:wd_alpha)
    assert_receive {:DOWN, ^ref, :process, ^pid, _}, 1_000
    wait_registered(:wd_alpha)

    # sibling untouched: same pid, same state
    assert Process.whereis(:wd_beta) == beta_pid
    assert Watchdog.Worker.value(:wd_beta) == 2
  end

  test "survives two crashes in a row" do
    for _ <- 1..2 do
      pid = Process.whereis(:wd_alpha)
      ref = Process.monitor(pid)
      Watchdog.Worker.crash(:wd_alpha)
      assert_receive {:DOWN, ^ref, :process, ^pid, _}, 1_000
      wait_registered(:wd_alpha)
    end

    assert Watchdog.Worker.value(:wd_alpha) == 0
    assert Watchdog.Worker.increment(:wd_alpha) == 1
  end
end
