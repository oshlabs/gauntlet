# Fast standalone checker for micro item files — authoring aid only.
# The authoritative gate stays `mix gauntlet.validate --suite micro`, which
# runs reference solutions through the real sandbox. This script evaluates
# items in-process (trusted repo content) so authors can iterate in seconds
# without mix build locks:
#
#     elixir priv/tasks/micro/check_items.exs priv/tasks/micro/enum.exs
#
# Exits non-zero if any item is malformed or its reference solution fails
# its own checks.

defmodule MicroItemCheck do
  @default_wrapper """
  defmodule Micro do
    def solve(input) do
      _ = input
      __SNIPPET__
    end
  end
  """

  def run(path) do
    {items, _} = Code.eval_file(path)

    unless is_list(items), do: fail("#{path} must evaluate to a list")

    ids = Enum.map(items, &Map.fetch!(&1, :id))
    dups = ids |> Enum.frequencies() |> Enum.filter(fn {_, n} -> n > 1 end)
    unless dups == [], do: fail("duplicate ids: #{inspect(dups)}")

    Code.compiler_options(ignore_module_conflict: true)
    Application.ensure_all_started(:ex_unit)

    failures =
      items
      |> Enum.with_index(1)
      |> Enum.flat_map(fn {item, idx} -> check_item(item, idx) end)

    case failures do
      [] ->
        IO.puts("#{length(items)} items ok (#{path})")

      _ ->
        Enum.each(failures, fn {id, msg} -> IO.puts("FAIL #{id}: #{msg}") end)
        fail("#{length(failures)} failing items in #{path}")
    end
  end

  defp check_item(item, idx) do
    with :ok <- shape(item),
         :ok <- compile(item) do
      run_checks(item)
    else
      {:error, msg} -> [{item[:id] || "item ##{idx}", msg}]
    end
  end

  defp shape(item) do
    cond do
      not is_map(item) -> {:error, "not a map"}
      not is_binary(item[:id]) -> {:error, "missing :id"}
      not is_binary(item[:prompt]) -> {:error, "missing :prompt"}
      not is_binary(item[:solution]) -> {:error, "missing :solution"}
      Map.get(item, :checks, []) == [] and Map.get(item, :raw_checks, []) == [] ->
        {:error, "no checks"}
      item[:difficulty] not in [nil, :easy, :medium, :hard] ->
        {:error, "bad difficulty #{inspect(item[:difficulty])}"}
      true -> :ok
    end
  end

  defp compile(item) do
    wrapper = Map.get(item, :wrapper, @default_wrapper)

    code =
      if item.solution =~ ~r/\bdefmodule\s+Micro\b/ do
        item.solution
      else
        String.replace(wrapper, "__SNIPPET__", String.trim(item.solution))
      end

    try do
      Code.eval_string(code)
      :ok
    rescue
      e -> {:error, "solution does not compile: #{Exception.message(e)}"}
    end
  end

  defp run_checks(item) do
    tuple_failures =
      item
      |> Map.get(:checks, [])
      |> Enum.with_index(1)
      |> Enum.flat_map(fn
        {{input_code, expected_code}, i} ->
          eval_check(item.id, "check #{i}", """
          input = #{input_code}
          result = Micro.solve(input)
          expected = (#{expected_code})

          if result == expected do
            :ok
          else
            raise "got " <> inspect(result) <> ", expected " <> inspect(expected)
          end
          """)

        {other, i} ->
          [{item.id, "check #{i} is not an {input, expected} tuple: #{inspect(other)}"}]
      end)

    raw_failures =
      item
      |> Map.get(:raw_checks, [])
      |> Enum.with_index(1)
      |> Enum.flat_map(fn {body, i} ->
        eval_check(item.id, "raw check #{i}", "import ExUnit.Assertions\n" <> body)
      end)

    tuple_failures ++ raw_failures
  end

  defp eval_check(id, label, code) do
    try do
      Code.eval_string(code)
      []
    rescue
      e -> [{id, "#{label}: #{Exception.message(e)}"}]
    catch
      kind, reason -> [{id, "#{label}: #{kind} #{inspect(reason)}"}]
    end
  end

  def fail(msg) do
    IO.puts(:stderr, msg)
    System.halt(1)
  end
end

case System.argv() do
  [path | _] -> MicroItemCheck.run(path)
  [] -> MicroItemCheck.fail("usage: elixir check_items.exs <items-file.exs>")
end
