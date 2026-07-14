defmodule ConfigValidatorTest do
  use ExUnit.Case, async: true

  alias ConfigValidator.Config

  test "minimal valid config applies defaults" do
    assert {:ok, %Config{host: "example.org", port: 4000, tls: false, tags: []}} =
             ConfigValidator.validate(%{"host" => "example.org"})
  end

  test "full valid config" do
    assert {:ok, %Config{host: "h", port: 443, tls: true, tags: [:a, :b]}} =
             ConfigValidator.validate(%{
               "host" => "h",
               "port" => 443,
               "tls" => true,
               "tags" => ["b", "a", "b"]
             })
  end

  test "missing host" do
    assert ConfigValidator.validate(%{}) == {:error, {:missing, :host}}
  end

  test "invalid host" do
    assert ConfigValidator.validate(%{"host" => ""}) == {:error, {:invalid, :host}}
    assert ConfigValidator.validate(%{"host" => 42}) == {:error, {:invalid, :host}}
  end

  test "port parses from string" do
    assert {:ok, %Config{port: 8080}} =
             ConfigValidator.validate(%{"host" => "h", "port" => "8080"})
  end

  test "invalid ports" do
    for bad <- [0, 65_536, -1, "80x", "x80", "", 3.14, true] do
      assert ConfigValidator.validate(%{"host" => "h", "port" => bad}) ==
               {:error, {:invalid, :port}},
             "expected port #{inspect(bad)} to be invalid"
    end
  end

  test "tls from strings" do
    assert {:ok, %Config{tls: true}} =
             ConfigValidator.validate(%{"host" => "h", "tls" => "true"})

    assert {:ok, %Config{tls: false}} =
             ConfigValidator.validate(%{"host" => "h", "tls" => "false"})
  end

  test "invalid tls" do
    for bad <- [1, "yes", nil] do
      assert ConfigValidator.validate(%{"host" => "h", "tls" => bad}) ==
               {:error, {:invalid, :tls}}
    end
  end

  test "tags normalize sorted unique atoms" do
    assert {:ok, %Config{tags: [:alpha, :beta]}} =
             ConfigValidator.validate(%{"host" => "h", "tags" => ["beta", "alpha", "beta"]})
  end

  test "invalid tags" do
    for bad <- ["not-a-list", [""], ["ok", 5], [nil]] do
      assert ConfigValidator.validate(%{"host" => "h", "tags" => bad}) ==
               {:error, {:invalid, :tags}}
    end
  end

  test "unknown keys checked first, sorted" do
    assert ConfigValidator.validate(%{"zzz" => 1, "abc" => 2}) ==
             {:error, {:unknown_keys, ["abc", "zzz"]}}
  end

  test "first error wins in field order" do
    assert ConfigValidator.validate(%{"host" => "", "port" => 0}) ==
             {:error, {:invalid, :host}}

    assert ConfigValidator.validate(%{"host" => "h", "port" => 0, "tls" => "nope"}) ==
             {:error, {:invalid, :port}}
  end
end
