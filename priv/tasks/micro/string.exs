# Micro items: String, Regex, Atom (Elixir 1.19).
# Strings containing `{` or `}` use ~S'...' because braces terminate ~S{...}.
[
  # ---------------------------------------------------------------- String
  %{
    id: "string/length-graphemes",
    prompt:
      ~S{`input` is a UTF-8 string. Return the number of characters as a user perceives them (grapheme clusters), as an integer.},
    solution: ~S{String.length(input)},
    checks: [
      {~S{"noël"}, ~S{4}},
      {~S{""}, ~S{0}},
      {~S{"héllo"}, ~S{5}}
    ],
    tags: [:string, :gotcha],
    difficulty: :easy
  },
  %{
    id: "string/graphemes",
    prompt:
      ~S{`input` is a UTF-8 string. Return the list of its grapheme clusters, each as a string, in order.},
    solution: ~S{String.graphemes(input)},
    checks: [
      {~S{"noël"}, ~S{["n", "o", "ë", "l"]}},
      {~S{""}, ~S{[]}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/split-comma",
    prompt:
      ~S{`input` is a string of comma-separated fields. Split it on commas and return the list of fields as strings; empty fields must be kept.},
    solution: ~S{String.split(input, ",")},
    checks: [
      {~S{"a,b,,c"}, ~S{["a", "b", "", "c"]}},
      {~S{""}, ~S{[""]}},
      {~S{"solo"}, ~S{["solo"]}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/replace-all",
    prompt:
      ~S{`input` is a string. Return it with every comma replaced by a dash ("-").},
    solution: ~S{String.replace(input, ",", "-")},
    checks: [
      {~S{"a,b,c"}, ~S{"a-b-c"}},
      {~S{""}, ~S{""}},
      {~S{"no commas"}, ~S{"no commas"}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/replace-prefix",
    prompt:
      ~S{`input` is a host name string. Return it with a leading "www." removed when present; strings without that exact prefix are returned unchanged, and a "www." occurring elsewhere must stay.},
    solution: ~S{String.replace_prefix(input, "www.", "")},
    checks: [
      {~S{"www.example.com"}, ~S{"example.com"}},
      {~S{"example.www.com"}, ~S{"example.www.com"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/replace-suffix",
    prompt:
      ~S{`input` is a file name string. Return it with a trailing ".txt" replaced by ".md"; names not ending in ".txt" are returned unchanged, and a ".txt" in the middle must stay.},
    solution: ~S{String.replace_suffix(input, ".txt", ".md")},
    checks: [
      {~S{"notes.txt"}, ~S{"notes.md"}},
      {~S{"a.txt.bak"}, ~S{"a.txt.bak"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/trim",
    prompt:
      ~S{`input` is a string. Return it with all leading and trailing whitespace removed.},
    solution: ~S{String.trim(input)},
    checks: [
      {~S{"  hi  "}, ~S{"hi"}},
      {~S{"\n a \t"}, ~S{"a"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/trim-leading",
    prompt:
      ~S{`input` is a string. Return it with leading whitespace removed; trailing whitespace must be kept.},
    solution: ~S{String.trim_leading(input)},
    checks: [
      {~S{"  hi "}, ~S{"hi "}},
      {~S{"hi"}, ~S{"hi"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/duplicate",
    prompt: ~S{`input` is a string. Return it repeated three times as one string.},
    solution: ~S{String.duplicate(input, 3)},
    checks: [
      {~S{"ab"}, ~S{"ababab"}},
      {~S{""}, ~S{""}},
      {~S{"x"}, ~S{"xxx"}}
    ],
    tags: [:string, :trap],
    difficulty: :easy
  },
  %{
    id: "string/reverse-unicode",
    prompt:
      ~S{`input` is a UTF-8 string. Return it reversed without breaking multibyte characters.},
    solution: ~S{String.reverse(input)},
    checks: [
      {~S{"noël"}, ~S{"lëon"}},
      {~S{"abc"}, ~S{"cba"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string, :gotcha],
    difficulty: :easy
  },
  %{
    id: "string/case-both",
    prompt:
      ~S'`input` is a UTF-8 string. Return the tuple {upcased, downcased} holding the fully uppercased and fully lowercased versions; accented letters must convert too.',
    solution: ~S'{String.upcase(input), String.downcase(input)}',
    checks: [
      {~S{"héllo"}, ~S'{"HÉLLO", "héllo"}'},
      {~S{"Ab"}, ~S'{"AB", "ab"}'},
      {~S{""}, ~S'{"", ""}'}
    ],
    tags: [:string, :gotcha],
    difficulty: :easy
  },
  %{
    id: "string/to-integer",
    prompt:
      ~S{`input` is a string containing a base-10 integer. Return it as an integer.},
    solution: ~S{String.to_integer(input)},
    checks: [
      {~S{"123"}, ~S{123}},
      {~S{"-45"}, ~S{-45}},
      {~S{"0"}, ~S{0}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/to-float",
    prompt:
      ~S{`input` is a string containing a float with a decimal point. Return it as a float.},
    solution: ~S{String.to_float(input)},
    checks: [
      {~S{"3.14"}, ~S{3.14}},
      {~S{"-0.5"}, ~S{-0.5}},
      {~S{"0.0"}, ~S{0.0}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/interpolation",
    prompt:
      ~S{`input` is an integer. Return the string "value: " followed by the number, e.g. 7 gives "value: 7".},
    solution: ~S'"value: #{input}"',
    checks: [
      {~S{42}, ~S{"value: 42"}},
      {~S{0}, ~S{"value: 0"}},
      {~S{-3}, ~S{"value: -3"}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/concat",
    prompt:
      ~S{`input` is a string. Return a new string consisting of the prefix "id-" followed by `input`.},
    solution: ~S{"id-" <> input},
    checks: [
      {~S{"42"}, ~S{"id-42"}},
      {~S{""}, ~S{"id-"}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/join-list",
    prompt:
      ~S{`input` is a list of strings. Return one string with the elements joined by a comma.},
    solution: ~S{Enum.join(input, ",")},
    checks: [
      {~S{["a", "b", "c"]}, ~S{"a,b,c"}},
      {~S{[]}, ~S{""}},
      {~S{["solo"]}, ~S{"solo"}}
    ],
    tags: [:string, :trap],
    difficulty: :easy
  },
  %{
    id: "string/match",
    prompt:
      ~S{`input` is a string. Return true if the whole string consists only of ASCII digits (at least one), false otherwise.},
    solution: ~S{String.match?(input, ~r/^[0-9]+$/)},
    checks: [
      {~S{"123"}, ~S{true}},
      {~S{"12a"}, ~S{false}},
      {~S{""}, ~S{false}}
    ],
    tags: [:string, :regex],
    difficulty: :easy
  },
  %{
    id: "string/first-last",
    prompt:
      ~S'`input` is a UTF-8 string. Return the tuple {first, last} of its first and last graphemes as strings; both elements are nil when the string is empty.',
    solution: ~S'{String.first(input), String.last(input)}',
    checks: [
      {~S{"héllo"}, ~S'{"h", "o"}'},
      {~S{""}, ~S'{nil, nil}'},
      {~S{"a"}, ~S'{"a", "a"}'}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/ends-with-any",
    prompt:
      ~S{`input` is a file name string. Return true if it ends with ".jpg" or ".png", false otherwise.},
    solution: ~S{String.ends_with?(input, [".jpg", ".png"])},
    checks: [
      {~S{"photo.png"}, ~S{true}},
      {~S{"doc.gif"}, ~S{false}},
      {~S{""}, ~S{false}}
    ],
    tags: [:string],
    difficulty: :easy
  },
  %{
    id: "string/length-vs-bytes",
    prompt:
      ~S'`input` is a UTF-8 string. Return the tuple {characters, bytes} holding the number of grapheme clusters and the number of bytes, both as integers.',
    solution: ~S'{String.length(input), byte_size(input)}',
    checks: [
      {~S{"ë"}, ~S'{1, 2}'},
      {~S{"abc"}, ~S'{3, 3}'},
      {~S{""}, ~S'{0, 0}'}
    ],
    tags: [:string, :gotcha],
    difficulty: :medium
  },
  %{
    id: "string/at-index",
    prompt:
      ~S'`input` is a tuple {string, index}. Return the grapheme of the string at the zero-based index, as a one-character string; a negative index counts from the end; return nil when the index is out of range.',
    solution: ~S{String.at(elem(input, 0), elem(input, 1))},
    checks: [
      {~S'{"héllo", 1}', ~S{"é"}},
      {~S'{"abc", -1}', ~S{"c"}},
      {~S'{"abc", 5}', ~S{nil}}
    ],
    tags: [:string, :gotcha],
    difficulty: :medium
  },
  %{
    id: "string/slice-substring",
    prompt:
      ~S'`input` is a tuple {string, start, count}. Return the substring of at most `count` graphemes beginning at zero-based index `start`; a negative `start` counts from the end of the string. Return "" when `start` is past the end.',
    solution: ~S{String.slice(elem(input, 0), elem(input, 1), elem(input, 2))},
    checks: [
      {~S'{"elixir", 1, 3}', ~S{"lix"}},
      {~S'{"elixir", -3, 2}', ~S{"xi"}},
      {~S'{"", 0, 2}', ~S{""}}
    ],
    tags: [:string, :trap],
    difficulty: :medium
  },
  %{
    id: "string/slice-range",
    prompt:
      ~S{`input` is a string. Return the graphemes at zero-based indices 1 through 3, inclusive, as a string; shorter strings return whatever falls inside that range.},
    solution: ~S{String.slice(input, 1..3)},
    checks: [
      {~S{"elixir"}, ~S{"lix"}},
      {~S{"ab"}, ~S{"b"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/split-trim",
    prompt:
      ~S{`input` is a string of words separated by spaces. Split it on spaces and return the list of words, discarding every empty string produced by leading, trailing or repeated spaces.},
    solution: ~S{String.split(input, " ", trim: true)},
    checks: [
      {~S{" a  b "}, ~S{["a", "b"]}},
      {~S{""}, ~S{[]}},
      {~S{"a b"}, ~S{["a", "b"]}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/split-parts",
    prompt:
      ~S{`input` is a string. Split it on commas into at most two parts and return the list of strings: everything after the first comma stays together as the second element.},
    solution: ~S{String.split(input, ",", parts: 2)},
    checks: [
      {~S{"a,b,c"}, ~S{["a", "b,c"]}},
      {~S{"abc"}, ~S{["abc"]}},
      {~S{""}, ~S{[""]}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/split-regex",
    prompt:
      ~S{`input` is a string. Split it on every run of one or more ASCII digits and return the resulting list of strings; empty fields are kept.},
    solution: ~S{String.split(input, ~r/[0-9]+/)},
    checks: [
      {~S{"a1b22c"}, ~S{["a", "b", "c"]}},
      {~S{"abc"}, ~S{["abc"]}},
      {~S{"1a"}, ~S{["", "a"]}}
    ],
    tags: [:string, :regex],
    difficulty: :medium
  },
  %{
    id: "string/split-at",
    prompt:
      ~S'`input` is a tuple {string, index}. Cut the string at the zero-based grapheme index and return the tuple of the two resulting strings; a negative index counts from the end.',
    solution: ~S{String.split_at(elem(input, 0), elem(input, 1))},
    checks: [
      {~S'{"elixir", 2}', ~S'{"el", "ixir"}'},
      {~S'{"elixir", -2}', ~S'{"elix", "ir"}'},
      {~S'{"", 3}', ~S'{"", ""}'}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/replace-first",
    prompt:
      ~S{`input` is a string. Return it with only the first comma replaced by a dash; any later commas must remain.},
    solution: ~S{String.replace(input, ",", "-", global: false)},
    checks: [
      {~S{"a,b,c"}, ~S{"a-b,c"}},
      {~S{"ab"}, ~S{"ab"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/trim-custom",
    prompt:
      ~S{`input` is a string. Return it with all leading and trailing "x" characters removed; other characters and inner "x" characters stay.},
    solution: ~S{String.trim(input, "x")},
    checks: [
      {~S{"xxaxbxx"}, ~S{"axb"}},
      {~S{"xx"}, ~S{""}},
      {~S{"abc"}, ~S{"abc"}}
    ],
    tags: [:string, :trap],
    difficulty: :medium
  },
  %{
    id: "string/trim-trailing-custom",
    prompt:
      ~S{`input` is a string. Return it with all trailing "!" characters removed; leading ones must stay.},
    solution: ~S{String.trim_trailing(input, "!")},
    checks: [
      {~S{"!hi!!!"}, ~S{"!hi"}},
      {~S{"hi"}, ~S{"hi"}},
      {~S{"!!!"}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/pad-left-zeros",
    prompt:
      ~S{`input` is a string of digits. Return it left-padded with "0" characters to a total length of 5; strings already 5 characters or longer are returned unchanged.},
    solution: ~S{String.pad_leading(input, 5, "0")},
    checks: [
      {~S{"42"}, ~S{"00042"}},
      {~S{"123456"}, ~S{"123456"}},
      {~S{""}, ~S{"00000"}}
    ],
    tags: [:string, :trap],
    difficulty: :medium
  },
  %{
    id: "string/pad-right-dots",
    prompt:
      ~S{`input` is a string. Return it right-padded with "." characters to a total length of 6; strings already 6 characters or longer are returned unchanged.},
    solution: ~S{String.pad_trailing(input, 6, ".")},
    checks: [
      {~S{"ab"}, ~S{"ab...."}},
      {~S{"abcdefg"}, ~S{"abcdefg"}},
      {~S{""}, ~S{"......"}}
    ],
    tags: [:string, :trap],
    difficulty: :medium
  },
  %{
    id: "string/capitalize",
    prompt:
      ~S{`input` is a UTF-8 string. Return it with the first grapheme uppercased and ALL remaining characters lowercased.},
    solution: ~S{String.capitalize(input)},
    checks: [
      {~S{"HELLO world"}, ~S{"Hello world"}},
      {~S{"énergie"}, ~S{"Énergie"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/starts-with-any",
    prompt:
      ~S{`input` is a URL string. Return true if it starts with "http://" or "https://", false otherwise.},
    solution: ~S{String.starts_with?(input, ["http://", "https://"])},
    checks: [
      {~S{"https://x"}, ~S{true}},
      {~S{"ftp://x"}, ~S{false}},
      {~S{""}, ~S{false}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/contains-any",
    prompt:
      ~S{`input` is a string. Return true if it contains "cat" or "dog" anywhere inside it, false otherwise.},
    solution: ~S{String.contains?(input, ["cat", "dog"])},
    checks: [
      {~S{"hotdog stand"}, ~S{true}},
      {~S{"bird"}, ~S{false}},
      {~S{""}, ~S{false}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/printable",
    prompt:
      ~S{`input` is a string. Return true if it contains only printable characters, false otherwise (for example, a NUL byte is not printable).},
    solution: ~S{String.printable?(input)},
    checks: [
      {~S{"abc" <> <<0>>}, ~S{false}},
      {~S{"héllo"}, ~S{true}},
      {~S{""}, ~S{true}}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/next-grapheme",
    prompt:
      ~S'`input` is a UTF-8 string. Return a tuple {first, rest} holding its first grapheme and the remainder of the string, or nil when the string is empty.',
    solution: ~S{String.next_grapheme(input)},
    checks: [
      {~S{"héllo"}, ~S'{"h", "éllo"}'},
      {~S{""}, ~S{nil}},
      {~S{"a"}, ~S'{"a", ""}'}
    ],
    tags: [:string],
    difficulty: :medium
  },
  %{
    id: "string/to-charlist",
    prompt:
      ~S{`input` is a UTF-8 string. Return it converted to a charlist (a list of Unicode codepoint integers).},
    solution: ~S{String.to_charlist(input)},
    checks: [
      {~S{"abc"}, ~S{[97, 98, 99]}},
      {~S{"é"}, ~S{[233]}},
      {~S{""}, ~S{[]}}
    ],
    tags: [:string, :gotcha],
    difficulty: :medium
  },
  %{
    id: "string/slice-to-end",
    prompt:
      ~S{`input` is a string. Return everything from zero-based grapheme index 2 to the end of the string; strings with 2 or fewer characters return "".},
    solution: ~S{String.slice(input, 2..-1//1)},
    checks: [
      {~S{"elixir"}, ~S{"ixir"}},
      {~S{"ab"}, ~S{""}},
      {~S{"héllo"}, ~S{"llo"}}
    ],
    tags: [:string],
    difficulty: :hard
  },
  %{
    id: "string/codepoints-decomposed",
    prompt:
      ~S{`input` is a UTF-8 string. Return the list of its Unicode codepoints as single-codepoint strings — combining marks must appear as separate entries, not merged into grapheme clusters.},
    solution: ~S{String.codepoints(input)},
    checks: [
      {~S{"e\u0301"}, ~S{["e", "\u0301"]}},
      {~S{"ab"}, ~S{["a", "b"]}},
      {~S{""}, ~S{[]}}
    ],
    tags: [:string, :gotcha],
    difficulty: :hard
  },
  %{
    id: "string/chunk-printable",
    prompt:
      ~S{`input` is a binary. Return the list of chunks obtained by grouping runs of consecutive printable characters and runs of consecutive non-printable bytes, each chunk as a binary, in order.},
    solution: ~S{String.chunk(input, :printable)},
    checks: [
      {~S{"abc" <> <<0>> <> "def"}, ~S{["abc", <<0>>, "def"]}},
      {~S{"abc"}, ~S{["abc"]}},
      {~S{""}, ~S{[]}}
    ],
    tags: [:string],
    difficulty: :hard
  },
  %{
    id: "string/prefix-pattern-match",
    prompt:
      ~S{`input` is a string. When it starts with the prefix "user:", return everything after that prefix; otherwise return nil.},
    solution: ~S{case input do "user:" <> rest -> rest; _ -> nil end},
    checks: [
      {~S{"user:anna"}, ~S{"anna"}},
      {~S{"admin:bob"}, ~S{nil}},
      {~S{"user:"}, ~S{""}}
    ],
    tags: [:string],
    difficulty: :hard
  },
  %{
    id: "string/count-occurrences",
    prompt:
      ~S'`input` is a tuple {string, pattern} of two strings. Return the number of non-overlapping occurrences of `pattern` inside `string`, scanning left to right, as an integer.',
    solution: ~S{String.count(elem(input, 0), elem(input, 1))},
    checks: [
      {~S'{"banana", "an"}', ~S{2}},
      {~S'{"aaa", "aa"}', ~S{1}},
      {~S'{"", "a"}', ~S{0}}
    ],
    tags: [:string, :drift],
    difficulty: :hard
  },
  %{
    id: "string/valid-bytes",
    prompt:
      ~S{`input` is a binary that may or may not be proper UTF-8. Return true if it is valid UTF-8, false otherwise.},
    solution: ~S{String.valid?(input)},
    checks: [
      {~S{<<0xFF>>}, ~S{false}},
      {~S{"héllo"}, ~S{true}},
      {~S{<<>>}, ~S{true}}
    ],
    tags: [:string],
    difficulty: :hard
  },
  %{
    id: "string/jaro",
    prompt:
      ~S'`input` is a tuple {a, b} of two strings. Return their Jaro distance as a float: 1.0 for equal strings and 0.0 for entirely dissimilar ones.',
    solution: ~S{String.jaro_distance(elem(input, 0), elem(input, 1))},
    checks: [
      {~S'{"dwayne", "duane"}', ~S{0.8222222222222223}},
      {~S'{"same", "same"}', ~S{1.0}},
      {~S'{"abc", "xyz"}', ~S{0.0}}
    ],
    tags: [:string],
    difficulty: :hard
  },

  # ---------------------------------------------------------------- Regex
  %{
    id: "regex/sigil-i",
    prompt:
      ~S{`input` is a string. Return true if it contains the word "error" in any letter case, false otherwise.},
    solution: ~S{input =~ ~r/error/i},
    checks: [
      {~S{"FATAL ERROR"}, ~S{true}},
      {~S{"all good"}, ~S{false}},
      {~S{"Error: x"}, ~S{true}}
    ],
    tags: [:regex],
    difficulty: :easy
  },
  %{
    id: "regex/tilde-match",
    prompt:
      ~S{`input` is a string. Return true if it contains at least one ASCII digit, false otherwise.},
    solution: ~S{input =~ ~r/[0-9]/},
    checks: [
      {~S{"abc1"}, ~S{true}},
      {~S{"abc"}, ~S{false}},
      {~S{""}, ~S{false}}
    ],
    tags: [:regex],
    difficulty: :easy
  },
  %{
    id: "regex/split-separators",
    prompt:
      ~S{`input` is a string of items separated by a comma or a semicolon, each separator optionally followed by spaces. Split it on those separators and return the list of items as strings.},
    solution: ~S{Regex.split(~r/[,;] */, input)},
    checks: [
      {~S{"a, b;c"}, ~S{["a", "b", "c"]}},
      {~S{"abc"}, ~S{["abc"]}},
      {~S{""}, ~S{[""]}}
    ],
    tags: [:regex],
    difficulty: :easy
  },
  %{
    id: "regex/multiline-anchors",
    prompt:
      ~S{`input` is a possibly multi-line string. Return the list of the first word of every line, in order; a word is a maximal run of word characters at the very start of the line, and lines not starting with a word character contribute nothing.},
    solution: ~S{Regex.scan(~r/^\w+/m, input) |> List.flatten()},
    checks: [
      {~S{"foo bar\nbaz qux"}, ~S{["foo", "baz"]}},
      {~S{"one"}, ~S{["one"]}},
      {~S{""}, ~S{[]}}
    ],
    tags: [:regex],
    difficulty: :medium
  },
  %{
    id: "regex/unicode-word",
    prompt:
      ~S{`input` is a string. Return true when the entire string is one or more word characters where accented Unicode letters also count as word characters, false otherwise.},
    solution: ~S{Regex.match?(~r/^\w+$/u, input)},
    checks: [
      {~S{"héllo"}, ~S{true}},
      {~S{"he llo"}, ~S{false}},
      {~S{""}, ~S{false}}
    ],
    tags: [:regex],
    difficulty: :medium
  },
  %{
    id: "regex/run-captures",
    prompt:
      ~S{`input` is a string containing at most one range like "10-20" (digits, dash, digits). Return the two numbers around the first such dash as a list of two strings, WITHOUT the overall match; return nil when there is no such range.},
    solution: ~S{Regex.run(~r/([0-9]+)-([0-9]+)/, input, capture: :all_but_first)},
    checks: [
      {~S{"10-20"}, ~S{["10", "20"]}},
      {~S{"from 3-4 ok"}, ~S{["3", "4"]}},
      {~S{"abc"}, ~S{nil}}
    ],
    tags: [:regex],
    difficulty: :medium
  },
  %{
    id: "regex/scan-digits",
    prompt:
      ~S{`input` is a string. Return the list of every run of consecutive ASCII digits found in it, in order, each as a string.},
    solution: ~S{Regex.scan(~r/[0-9]+/, input) |> List.flatten()},
    checks: [
      {~S{"a1 b22 c333"}, ~S{["1", "22", "333"]}},
      {~S{""}, ~S{[]}},
      {~S{"abc"}, ~S{[]}}
    ],
    tags: [:regex],
    difficulty: :medium
  },
  %{
    id: "regex/escape",
    prompt:
      ~S{`input` is a string that may contain regex metacharacters. Return a version where every metacharacter is backslash-escaped, so the result matches `input` literally when embedded in a regex.},
    solution: ~S{Regex.escape(input)},
    checks: [
      {~S{"1.5+2"}, ~S{"1\\.5\\+2"}},
      {~S{"abc"}, ~S{"abc"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:regex],
    difficulty: :medium
  },
  %{
    id: "regex/dotall",
    prompt:
      ~S{`input` is a string. Return true when it is exactly three characters long and reads "a", then any single character (which may be a newline), then "b"; false otherwise.},
    solution: ~S{Regex.match?(~r/^a.b$/s, input)},
    checks: [
      {~S{"a\nb"}, ~S{true}},
      {~S{"axb"}, ~S{true}},
      {~S{"ab"}, ~S{false}}
    ],
    tags: [:regex],
    difficulty: :hard
  },
  %{
    id: "regex/replace-backrefs",
    prompt:
      ~S{`input` is a string containing at most one email-like token "name@host" (word characters on both sides of the @). Return the string with that token rewritten as "host@name"; everything else stays unchanged.},
    solution: ~S{Regex.replace(~r/(\w+)@(\w+)/, input, "\\2@\\1")},
    checks: [
      {~S{"user@host"}, ~S{"host@user"}},
      {~S{"hi bob@work today"}, ~S{"hi work@bob today"}},
      {~S{"abc"}, ~S{"abc"}}
    ],
    tags: [:regex],
    difficulty: :hard
  },
  %{
    id: "regex/replace-fun",
    prompt:
      ~S{`input` is a string. Return it with every run of consecutive ASCII digits replaced by the same number of "*" characters.},
    solution:
      ~S{Regex.replace(~r/[0-9]+/, input, fn m -> String.duplicate("*", String.length(m)) end)},
    checks: [
      {~S{"a1b22"}, ~S{"a*b**"}},
      {~S{"abc"}, ~S{"abc"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:regex],
    difficulty: :hard
  },
  %{
    id: "regex/named-captures",
    prompt:
      ~S{`input` is a string. When it contains a date like "2024-07" (four digits, a dash, two digits), return a map with the keys "y" and "m" bound to those two digit groups as strings; return nil when no such date occurs.},
    solution: ~S'Regex.named_captures(~r/(?<y>[0-9]{4})-(?<m>[0-9]{2})/, input)',
    checks: [
      {~S{"2024-07"}, ~S'%{"y" => "2024", "m" => "07"}'},
      {~S{"born 1999-12."}, ~S'%{"y" => "1999", "m" => "12"}'},
      {~S{"nope"}, ~S{nil}}
    ],
    tags: [:regex],
    difficulty: :hard
  },

  # ---------------------------------------------------------------- Atom
  %{
    id: "atom/to-string",
    prompt: ~S{`input` is an atom. Return its name as a string.},
    solution: ~S{Atom.to_string(input)},
    checks: [
      {~S{:hello}, ~S{"hello"}},
      {~S{:ok}, ~S{"ok"}},
      {~S{:""}, ~S{""}}
    ],
    tags: [:atom],
    difficulty: :easy
  },
  %{
    id: "atom/is-atom",
    prompt: ~S{`input` may be any term. Return true when it is an atom, false otherwise.},
    solution: ~S{is_atom(input)},
    checks: [
      {~S{true}, ~S{true}},
      {~S{nil}, ~S{true}},
      {~S{"x"}, ~S{false}}
    ],
    tags: [:atom, :gotcha],
    difficulty: :easy
  },
  %{
    id: "atom/from-trusted-string",
    prompt:
      ~S{`input` is a string coming from a trusted, fixed configuration file. Return the atom with that exact name, creating it if it does not exist yet.},
    solution: ~S{String.to_atom(input)},
    checks: [
      {~S{"error"}, ~S{:error}},
      {~S{"a b"}, ~S{:"a b"}},
      {~S{"Ok"}, ~S{:Ok}}
    ],
    tags: [:atom],
    difficulty: :easy
  },
  %{
    id: "atom/safe-existing",
    prompt:
      ~S{`input` is a user-supplied string. Convert it to an atom using the conversion that is safe for untrusted input: it must return the already-existing atom of that name, and raise ArgumentError when no such atom exists yet.},
    solution: ~S{String.to_existing_atom(input)},
    checks: [
      {~S{"ok"}, ~S{:ok}},
      {~S{"error"}, ~S{:error}}
    ],
    raw_checks: [
      ~S{assert_raise ArgumentError, fn -> Micro.solve("zz_gauntlet_micro_never_exists_zz") end}
    ],
    tags: [:atom],
    difficulty: :medium
  },
  %{
    id: "atom/module-name",
    prompt:
      ~S{`input` is an atom that may be an Elixir module name (such as the Enum module) or a plain atom. Return its complete underlying name as a string, exactly as stored in the runtime.},
    solution: ~S{Atom.to_string(input)},
    checks: [
      {~S{Enum}, ~S{"Elixir.Enum"}},
      {~S{String}, ~S{"Elixir.String"}},
      {~S{:erlang}, ~S{"erlang"}}
    ],
    tags: [:atom, :gotcha],
    difficulty: :hard
  }
]
