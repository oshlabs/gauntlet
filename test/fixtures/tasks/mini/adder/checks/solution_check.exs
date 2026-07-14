defmodule AdderTest do
  use ExUnit.Case, async: true

  test "adds" do
    assert Adder.add(1, 2) == 3
    assert Adder.add(-1, 1) == 0
  end
end
