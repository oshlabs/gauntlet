defmodule FrequencyMapTest do
  use ExUnit.Case, async: true

  test "counts simple words" do
    assert FrequencyMap.words("one two two three three three") ==
             %{"one" => 1, "two" => 2, "three" => 3}
  end

  test "is case insensitive with downcased keys" do
    assert FrequencyMap.words("The the THE tHe") == %{"the" => 4}
  end

  test "punctuation separates words" do
    assert FrequencyMap.words("a,b;c.d!e?f:g") ==
             %{"a" => 1, "b" => 1, "c" => 1, "d" => 1, "e" => 1, "f" => 1, "g" => 1}
  end

  test "inner apostrophes are part of the word, outer ones are not" do
    assert FrequencyMap.words("'Don't stop', she said - don't!") ==
             %{"don't" => 2, "stop" => 1, "she" => 1, "said" => 1}
  end

  test "digits count as word characters" do
    assert FrequencyMap.words("catch22 catch22 catch 22") ==
             %{"catch22" => 2, "catch" => 1, "22" => 1}
  end

  test "unicode letters are words" do
    assert FrequencyMap.words("über Über crème CRÈME") == %{"über" => 2, "crème" => 2}
  end

  test "empty string" do
    assert FrequencyMap.words("") == %{}
  end

  test "string with no words" do
    assert FrequencyMap.words("... --- !!!") == %{}
  end
end
