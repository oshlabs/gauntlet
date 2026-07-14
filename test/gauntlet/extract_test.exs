defmodule Gauntlet.ExtractTest do
  use ExUnit.Case, async: true

  alias Gauntlet.Extract

  describe "code_block/1" do
    test "extracts a single elixir block" do
      text = "Here you go:\n```elixir\ndefmodule A do\nend\n```\nDone."
      assert Extract.code_block(text) == "defmodule A do\nend"
    end

    test "takes the LAST elixir block" do
      text = """
      First try:
      ```elixir
      defmodule Wrong do
      end
      ```
      Actually, here is the fix:
      ```elixir
      defmodule Right do
      end
      ```
      """

      assert Extract.code_block(text) =~ "Right"
      refute Extract.code_block(text) =~ "Wrong"
    end

    test "falls back to plain fence" do
      assert Extract.code_block("```\n:ok\n```") == ":ok"
    end

    test "nil when no code" do
      assert Extract.code_block("no code here") == nil
      assert Extract.code_block("") == nil
    end

    test "nil for empty block" do
      assert Extract.code_block("```elixir\n\n```") == nil
    end
  end

  describe "snippet/1" do
    test "prefers fenced block" do
      assert Extract.snippet("Here:\n```elixir\nEnum.sum(input)\n```") == "Enum.sum(input)"
    end

    test "accepts a bare single-line reply" do
      assert Extract.snippet("String.upcase(input)") == "String.upcase(input)"
    end

    test "rejects multi-line prose without a fence" do
      assert Extract.snippet("I think you should\nuse String.upcase here") == nil
    end
  end

  describe "output_block/1" do
    test "extracts output block" do
      assert Extract.output_block("```output\nhello\n```") == "hello"
    end

    test "falls back to full text" do
      assert Extract.output_block("  just this  ") == "just this"
    end
  end

  describe "mcq_answer/1" do
    test "extracts the letter" do
      assert Extract.mcq_answer("Reasoning...\nANSWER: B") == "B"
    end

    test "takes the last answer and upcases" do
      assert Extract.mcq_answer("ANSWER: a\nWait...\nANSWER: c") == "C"
    end

    test "nil when absent" do
      assert Extract.mcq_answer("I think it is B.") == nil
    end
  end
end
