defmodule TaggableTest do
  use ExUnit.Case, async: true

  defmodule Article do
    use Taggable, tags: [:draft, :published, :archived]
  end

  defmodule Ticket do
    use Taggable, tags: [:open, :closed]
  end

  test "tags/0 in declaration order" do
    assert Article.tags() == [:draft, :published, :archived]
    assert Ticket.tags() == [:open, :closed]
  end

  test "predicates test membership" do
    assert Article.draft?([:draft, :other])
    refute Article.draft?([:published])
    assert Article.archived?([:archived])
    refute Article.archived?([])
  end

  test "predicates are compiled functions" do
    functions = Article.__info__(:functions)

    for f <- [:draft?, :published?, :archived?] do
      assert {f, 1} in functions, "expected #{f}/1 in __info__(:functions)"
    end
  end

  test "vocabularies do not interfere" do
    assert Ticket.open?([:open])
    refute {:draft?, 1} in Ticket.__info__(:functions)
    refute {:open?, 1} in Article.__info__(:functions)
  end

  test "valid?/1" do
    assert Article.valid?([])
    assert Article.valid?([:draft, :archived])
    refute Article.valid?([:draft, :bogus])
  end

  test "missing or empty tags raise at compile time" do
    for bad_use <- ["use Taggable", "use Taggable, tags: []"] do
      assert_raise CompileError, fn ->
        try do
          Code.compile_string("""
          defmodule BadUse#{System.unique_integer([:positive])} do
            #{bad_use}
          end
          """)
        rescue
          e in [ArgumentError] -> reraise CompileError, [description: e.message], __STACKTRACE__
        end
      end
    end
  end
end
