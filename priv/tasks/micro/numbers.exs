# Micro items: numbers — integers, floats, binaries/bitstrings, bitwise,
# ranges, and Erlang numeric/binary interop. See AUTHORING.md.

[
  # ---------------------------------------------------------------- Integer

  %{
    id: "numbers/int-parse-rest",
    prompt:
      ~S{`input` is a string. Return the result of parsing a leading base-10 integer from it: a tuple of the integer and the unparsed remainder string, or the atom `:error` if `input` does not start with an integer.},
    solution: ~S{Integer.parse(input)},
    checks: [
      {~S{"42abc"}, ~S({42, "abc"})},
      {~S{"-12rest"}, ~S({-12, "rest"})},
      {~S{"abc"}, ~S{:error}}
    ],
    tags: [:integer],
    difficulty: :medium
  },
  %{
    id: "numbers/int-strict-convert",
    prompt:
      ~S{`input` is a string. Return it converted to a base-10 integer. The conversion must be strict: it should raise `ArgumentError` when `input` is not a valid integer string (for example `"12.5"`).},
    solution: ~S{String.to_integer(input)},
    checks: [
      {~S{"123"}, ~S{123}},
      {~S{"-7"}, ~S{-7}}
    ],
    raw_checks: [
      ~S{assert_raise ArgumentError, fn -> Micro.solve("12.5") end}
    ],
    tags: [:integer, :gotcha],
    difficulty: :easy
  },
  %{
    id: "numbers/int-parse-hex",
    prompt:
      ~S{`input` is a string of hexadecimal digits (case-insensitive, no `0x` prefix, always fully valid). Return its integer value.},
    solution: ~S{String.to_integer(input, 16)},
    checks: [
      {~S{"ff"}, ~S{255}},
      {~S{"DEAD"}, ~S{57005}},
      {~S{"0"}, ~S{0}}
    ],
    tags: [:integer],
    difficulty: :medium
  },
  %{
    id: "numbers/int-to-hex",
    prompt:
      ~S{`input` is a non-negative integer. Return its hexadecimal representation as an UPPERCASE string (no prefix).},
    solution: ~S{Integer.to_string(input, 16)},
    checks: [
      {~S{255}, ~S{"FF"}},
      {~S{0}, ~S{"0"}},
      {~S{4096}, ~S{"1000"}}
    ],
    tags: [:integer],
    difficulty: :medium
  },
  %{
    id: "numbers/int-digits",
    prompt:
      ~S{`input` is a non-negative integer. Return the list of its base-10 digits, most significant first.},
    solution: ~S{Integer.digits(input)},
    checks: [
      {~S{1234}, ~S{[1, 2, 3, 4]}},
      {~S{0}, ~S{[0]}},
      {~S{7}, ~S{[7]}}
    ],
    tags: [:integer],
    difficulty: :easy
  },
  %{
    id: "numbers/int-digits-base2",
    prompt:
      ~S{`input` is a non-negative integer. Return the list of its base-2 (binary) digits, most significant first.},
    solution: ~S{Integer.digits(input, 2)},
    checks: [
      {~S{10}, ~S{[1, 0, 1, 0]}},
      {~S{1}, ~S{[1]}},
      {~S{0}, ~S{[0]}}
    ],
    tags: [:integer],
    difficulty: :medium
  },
  %{
    id: "numbers/int-undigits-hex",
    prompt:
      ~S{`input` is a non-empty list of base-16 digit values (integers 0-15), most significant first. Return the integer they represent.},
    solution: ~S{Integer.undigits(input, 16)},
    checks: [
      {~S{[15, 15]}, ~S{255}},
      {~S{[1, 0]}, ~S{16}},
      {~S{[0]}, ~S{0}}
    ],
    tags: [:integer],
    difficulty: :medium
  },
  %{
    id: "numbers/int-gcd",
    prompt:
      ~S(`input` is a tuple `{a, b}` of non-negative integers. Return their greatest common divisor as an integer.),
    solution: ~S{Integer.gcd(elem(input, 0), elem(input, 1))},
    checks: [
      {~S({12, 18}), ~S{6}},
      {~S({0, 5}), ~S{5}},
      {~S({7, 7}), ~S{7}}
    ],
    tags: [:integer],
    difficulty: :easy
  },
  %{
    id: "numbers/int-pow",
    prompt:
      ~S[`input` is a tuple `{base, exp}` of integers with `exp >= 0`. Return `base` raised to the power `exp` as an INTEGER (e.g. `1024`, not `1024.0`).],
    solution: ~S[case input do {b, e} -> Integer.pow(b, e) end],
    checks: [
      {~S({2, 10}), ~S{1024}},
      {~S({5, 0}), ~S{1}},
      {~S({3, 4}), ~S{81}}
    ],
    tags: [:integer, :trap],
    difficulty: :medium
  },
  %{
    id: "numbers/int-mod-negative",
    prompt:
      ~S{`input` is an integer, possibly negative. Return `input` modulo 4 using floored modulo semantics: the result always takes the sign of the divisor, so it is always in `0..3`.},
    solution: ~S{Integer.mod(input, 4)},
    checks: [
      {~S{-7}, ~S{1}},
      {~S{7}, ~S{3}},
      {~S{-4}, ~S{0}}
    ],
    tags: [:integer, :gotcha],
    difficulty: :hard
  },
  %{
    id: "numbers/int-rem-negative",
    prompt:
      ~S{`input` is an integer, possibly negative. Return the remainder of `input` divided by 4 using truncated division semantics: the result takes the sign of the dividend `input`.},
    solution: ~S{rem(input, 4)},
    checks: [
      {~S{-7}, ~S{-3}},
      {~S{7}, ~S{3}},
      {~S{-8}, ~S{0}}
    ],
    tags: [:integer, :gotcha],
    difficulty: :hard
  },
  %{
    id: "numbers/int-floor-div",
    prompt:
      ~S[`input` is a tuple `{a, b}` of integers, `b` positive. Return the integer quotient of `a` by `b`, rounded toward negative infinity (floored division, not truncation).],
    solution: ~S[case input do {a, b} -> Integer.floor_div(a, b) end],
    checks: [
      {~S({-7, 2}), ~S{-4}},
      {~S({7, 2}), ~S{3}},
      {~S({-6, 3}), ~S{-2}}
    ],
    tags: [:integer, :gotcha],
    difficulty: :hard
  },
  %{
    id: "numbers/int-abs",
    prompt: ~S{`input` is an integer. Return its absolute value as an integer.},
    solution: ~S{abs(input)},
    checks: [
      {~S{-5}, ~S{5}},
      {~S{0}, ~S{0}},
      {~S{7}, ~S{7}}
    ],
    tags: [:integer, :trap],
    difficulty: :easy
  },
  %{
    id: "numbers/int-leading-int",
    prompt:
      ~S{`input` is a string that starts with a (possibly negative) integer, optionally followed by other characters such as a decimal fraction or units (e.g. "12.5", "-3.9km"). Return only the leading integer, as an integer.},
    solution: ~S{Integer.parse(input) |> elem(0)},
    checks: [
      {~S{"12.5"}, ~S{12}},
      {~S{"7"}, ~S{7}},
      {~S{"-3.9km"}, ~S{-3}}
    ],
    tags: [:integer, :trap],
    difficulty: :medium
  },

  # ------------------------------------------------------------------ Float

  %{
    id: "numbers/float-round-2",
    prompt:
      ~S{`input` is a float. Return it rounded to 2 decimal places, as a float. Ties on the decimal representation round away from zero (e.g. 0.125 becomes 0.13).},
    solution: ~S{Float.round(input, 2)},
    checks: [
      {~S{1.5678}, ~S{1.57}},
      {~S{0.125}, ~S{0.13}},
      {~S{2.0}, ~S{2.0}}
    ],
    tags: [:float],
    difficulty: :medium
  },
  %{
    id: "numbers/float-round-half",
    prompt:
      ~S{`input` is a float. Return it rounded to the nearest whole number, returned as a FLOAT (e.g. `3.0`, not the integer `3`). Ties (halves) round away from zero.},
    solution: ~S{Float.round(input)},
    checks: [
      {~S{2.5}, ~S{3.0}},
      {~S{-2.5}, ~S{-3.0}},
      {~S{1.4}, ~S{1.0}}
    ],
    tags: [:float, :gotcha, :trap],
    difficulty: :hard
  },
  %{
    id: "numbers/float-ceil-1",
    prompt:
      ~S{`input` is a float. Return it rounded up (toward positive infinity) to 1 decimal place, as a float.},
    solution: ~S{Float.ceil(input, 1)},
    checks: [
      {~S{1.234}, ~S{1.3}},
      {~S{-1.234}, ~S{-1.2}},
      {~S{2.0}, ~S{2.0}}
    ],
    tags: [:float],
    difficulty: :medium
  },
  %{
    id: "numbers/float-parse",
    prompt:
      ~S{`input` is a string. Return the result of parsing a leading number from it: a tuple of the number as a FLOAT (even for plain integers like "5") and the unparsed remainder string, or the atom `:error` if `input` does not start with a number.},
    solution: ~S{Float.parse(input)},
    checks: [
      {~S{"3.14abc"}, ~S({3.14, "abc"})},
      {~S{"5"}, ~S({5.0, ""})},
      {~S{"abc"}, ~S{:error}}
    ],
    tags: [:float],
    difficulty: :medium
  },
  %{
    id: "numbers/float-sum-eq",
    prompt:
      ~S{`input` is a list of exactly three floats `[a, b, c]`. Return the boolean of whether `a + b` is exactly equal (`==`) to `c` — no rounding or tolerance.},
    solution: ~S{case input do [a, b, c] -> a + b == c end},
    checks: [
      {~S{[0.1, 0.2, 0.3]}, ~S{false}},
      {~S{[1.0, 2.0, 3.0]}, ~S{true}},
      {~S{[0.5, 0.25, 0.75]}, ~S{true}}
    ],
    tags: [:float, :gotcha],
    difficulty: :hard
  },
  %{
    id: "numbers/float-trunc",
    prompt:
      ~S{`input` is a float. Return its whole part as an INTEGER, dropping the fractional part (truncation toward zero, no rounding).},
    solution: ~S{trunc(input)},
    checks: [
      {~S{-3.7}, ~S{-3}},
      {~S{3.9}, ~S{3}},
      {~S{0.5}, ~S{0}}
    ],
    tags: [:float, :trap],
    difficulty: :easy
  },
  %{
    id: "numbers/float-div",
    prompt:
      ~S[`input` is a tuple `{a, b}` of integers, `b` non-zero. Return `a` divided by `b`. The result must be a float even when the division is exact (e.g. `2.0`, not `2`).],
    solution: ~S{elem(input, 0) / elem(input, 1)},
    checks: [
      {~S({10, 5}), ~S{2.0}},
      {~S({7, 2}), ~S{3.5}},
      {~S({-9, 3}), ~S{-3.0}}
    ],
    tags: [:float, :gotcha],
    difficulty: :easy
  },
  %{
    id: "numbers/float-neg-exp",
    prompt:
      ~S{`input` is a positive integer. Return `input` raised to the power `-2` (that is, `1 / input²`).},
    solution: ~S{input ** -2},
    checks: [
      {~S{2}, ~S{0.25}},
      {~S{4}, ~S{0.0625}},
      {~S{1}, ~S{1.0}}
    ],
    tags: [:float, :gotcha],
    difficulty: :hard
  },

  # ------------------------------------------- Binaries and bitstrings

  %{
    id: "numbers/bin-build",
    prompt:
      ~S{`input` is a list of exactly three integers, each in 0..255. Return a 3-byte binary containing those bytes in order.},
    solution: ~S{case input do [a, b, c] -> <<a, b, c>> end},
    checks: [
      {~S{[1, 2, 3]}, ~S{<<1, 2, 3>>}},
      {~S{[0, 255, 0]}, ~S{<<0, 255, 0>>}}
    ],
    tags: [:binary],
    difficulty: :easy
  },
  %{
    id: "numbers/bin-byte-size",
    prompt:
      ~S{`input` is a binary (possibly a UTF-8 string). Return its size in BYTES (not characters) as an integer.},
    solution: ~S{byte_size(input)},
    checks: [
      {~S{<<1, 2, 3>>}, ~S{3}},
      {~S{<<>>}, ~S{0}},
      {~S{"héllo"}, ~S{6}}
    ],
    tags: [:binary],
    difficulty: :easy
  },
  %{
    id: "numbers/bin-bit-size",
    prompt: ~S{`input` is a bitstring. Return its size in BITS as an integer.},
    solution: ~S{bit_size(input)},
    checks: [
      {~S{<<1, 2, 3>>}, ~S{24}},
      {~S{<<1::4>>}, ~S{4}},
      {~S{<<>>}, ~S{0}}
    ],
    tags: [:binary],
    difficulty: :easy
  },
  %{
    id: "numbers/bin-head-rest",
    prompt:
      ~S[`input` is a non-empty binary. Return a tuple `{first, rest}` where `first` is the first byte as an integer and `rest` is the remaining binary (possibly empty).],
    solution: ~S(case input do <<first, rest::binary>> -> {first, rest} end),
    checks: [
      {~S{<<10, 20, 30>>}, ~S({10, <<20, 30>>})},
      {~S{<<5>>}, ~S({5, <<>>})}
    ],
    tags: [:binary],
    difficulty: :medium
  },
  %{
    id: "numbers/bin-u16-big",
    prompt:
      ~S{`input` is a binary of at least 2 bytes. Return the unsigned integer decoded from its FIRST two bytes interpreted in big-endian byte order.},
    solution: ~S{case input do <<x::16-big, _::binary>> -> x end},
    checks: [
      {~S{<<1, 2>>}, ~S{258}},
      {~S{<<1, 2, 3>>}, ~S{258}},
      {~S{<<0, 7>>}, ~S{7}}
    ],
    tags: [:binary],
    difficulty: :medium
  },
  %{
    id: "numbers/bin-u16-little",
    prompt:
      ~S{`input` is a binary of at least 2 bytes. Return the unsigned integer decoded from its FIRST two bytes interpreted in little-endian byte order.},
    solution: ~S{case input do <<x::16-little, _::binary>> -> x end},
    checks: [
      {~S{<<1, 2>>}, ~S{513}},
      {~S{<<1, 2, 3>>}, ~S{513}},
      {~S{<<7, 0>>}, ~S{7}}
    ],
    tags: [:binary],
    difficulty: :hard
  },
  %{
    id: "numbers/bin-first3",
    prompt:
      ~S{`input` is a binary of at least 3 bytes. Return its first 3 bytes as a binary.},
    solution: ~S{case input do <<prefix::binary-size(3), _::binary>> -> prefix end},
    checks: [
      {~S{"hello"}, ~S{"hel"}},
      {~S{<<1, 2, 3>>}, ~S{<<1, 2, 3>>}}
    ],
    tags: [:binary],
    difficulty: :medium
  },
  %{
    id: "numbers/bin-utf8-first",
    prompt:
      ~S{`input` is a non-empty UTF-8 encoded string. Return the integer Unicode codepoint of its FIRST character (not its first byte).},
    solution: ~S{case input do <<cp::utf8, _::binary>> -> cp end},
    checks: [
      {~S{"abc"}, ~S{97}},
      {~S{"é!"}, ~S{233}},
      {~S{"→x"}, ~S{8594}}
    ],
    tags: [:binary],
    difficulty: :medium
  },
  %{
    id: "numbers/bin-copy",
    prompt:
      ~S[`input` is a tuple `{bin, n}` of a binary and a non-negative integer. Return `bin` repeated `n` times, concatenated into a single binary (`n` may be 0, giving the empty binary).],
    solution: ~S[case input do {bin, n} -> :binary.copy(bin, n) end],
    checks: [
      {~S({<<1, 2>>, 3}), ~S{<<1, 2, 1, 2, 1, 2>>}},
      {~S({"ab", 0}), ~S{""}}
    ],
    tags: [:binary, :erlang],
    difficulty: :easy
  },
  %{
    id: "numbers/bin-part",
    prompt:
      ~S(`input` is a tuple `{bin, start, length}`: a binary, a zero-based byte offset, and a byte count. Return the sub-binary of `bin` starting at `start` with `length` bytes.),
    solution: ~S[case input do {bin, start, len} -> binary_part(bin, start, len) end],
    checks: [
      {~S({"hello world", 6, 5}), ~S{"world"}},
      {~S({"abc", 0, 0}), ~S{""}},
      {~S({"abc", 1, 2}), ~S{"bc"}}
    ],
    tags: [:binary],
    difficulty: :easy
  },
  %{
    id: "numbers/bin-for-into",
    prompt:
      ~S{`input` is a list of integers, each in 0..100. Return a binary whose consecutive bytes are each input value doubled, in order. An empty list gives the empty binary.},
    solution: ~S{for x <- input, into: <<>>, do: <<x * 2>>},
    checks: [
      {~S{[1, 2, 3]}, ~S{<<2, 4, 6>>}},
      {~S{[]}, ~S{<<>>}},
      {~S{[100]}, ~S{<<200>>}}
    ],
    tags: [:binary],
    difficulty: :medium
  },
  %{
    id: "numbers/bin-vs-bitstring",
    prompt:
      ~S{`input` is a bitstring. Return `true` if its total bit count is a multiple of 8 (i.e. it is made of whole bytes), `false` otherwise.},
    solution: ~S{is_binary(input)},
    checks: [
      {~S{<<1::4>>}, ~S{false}},
      {~S{<<1, 2>>}, ~S{true}},
      {~S{<<>>}, ~S{true}}
    ],
    tags: [:binary, :gotcha],
    difficulty: :hard
  },
  %{
    id: "numbers/bin-byte-code",
    prompt:
      ~S{`input` is a binary of exactly one byte. Return that byte's integer value.},
    solution: ~S{case input do <<c>> -> c end},
    checks: [
      {~S{"A"}, ~S{65}},
      {~S{<<0>>}, ~S{0}},
      {~S{"z"}, ~S{122}}
    ],
    tags: [:binary],
    difficulty: :easy
  },
  %{
    id: "numbers/bin-match",
    prompt:
      ~S(`input` is a tuple `{haystack, needle}` of binaries, `needle` non-empty. Return a tuple `{start, length}` giving the zero-based byte offset and byte length of the first occurrence of `needle` in `haystack`, or the atom `:nomatch` if it does not occur.),
    solution: ~S[case input do {haystack, needle} -> :binary.match(haystack, needle) end],
    checks: [
      {~S({"hello world", "world"}), ~S({6, 5})},
      {~S({"hello", "xyz"}), ~S{:nomatch}}
    ],
    tags: [:binary, :erlang],
    difficulty: :medium
  },
  %{
    id: "numbers/bin-fields",
    prompt:
      ~S(`input` is exactly a 4-byte binary encoding three unsigned big-endian fields: an 8-bit `a`, a 16-bit `b`, and an 8-bit `c`. Return the tuple `{a, b, c}` of integers.),
    solution: ~S(case input do <<a::8, b::16, c::8>> -> {a, b, c} end),
    checks: [
      {~S{<<1, 0, 2, 3>>}, ~S({1, 2, 3})},
      {~S{<<255, 255, 255, 255>>}, ~S({255, 65535, 255})}
    ],
    tags: [:binary],
    difficulty: :hard
  },
  %{
    id: "numbers/bin-concat",
    prompt:
      ~S(`input` is a tuple `{a, b}` of two binaries. Return their concatenation `a` then `b` as a single binary.),
    solution: ~S{elem(input, 0) <> elem(input, 1)},
    checks: [
      {~S({"foo", "bar"}), ~S{"foobar"}},
      {~S({<<1>>, <<2>>}), ~S{<<1, 2>>}},
      {~S({"", "x"}), ~S{"x"}}
    ],
    tags: [:binary],
    difficulty: :easy
  },

  # ---------------------------------------------------------------- Bitwise

  %{
    id: "numbers/bit-and",
    prompt:
      ~S(`input` is a tuple `{a, b}` of non-negative integers. Return their bitwise AND as an integer.),
    solution: ~S{Bitwise.band(elem(input, 0), elem(input, 1))},
    checks: [
      {~S({12, 10}), ~S{8}},
      {~S({255, 0}), ~S{0}}
    ],
    tags: [:bitwise],
    difficulty: :easy
  },
  %{
    id: "numbers/bit-xor",
    prompt:
      ~S[`input` is a tuple `{a, b}` of non-negative integers. Return their bitwise XOR (exclusive or) as an integer.],
    solution: ~S{Bitwise.bxor(elem(input, 0), elem(input, 1))},
    checks: [
      {~S({12, 10}), ~S{6}},
      {~S({7, 7}), ~S{0}}
    ],
    tags: [:bitwise],
    difficulty: :easy
  },
  %{
    id: "numbers/bit-mask-low-byte",
    prompt:
      ~S{`input` is a non-negative integer. Return its lowest byte (the value of `input` masked with `0xFF`) as an integer.},
    solution: ~S{Bitwise.band(input, 0xFF)},
    checks: [
      {~S{0x1234}, ~S{52}},
      {~S{255}, ~S{255}},
      {~S{256}, ~S{0}}
    ],
    tags: [:bitwise],
    difficulty: :easy
  },
  %{
    id: "numbers/bit-shl",
    prompt:
      ~S(`input` is a tuple `{a, n}` of non-negative integers. Return `a` shifted LEFT by `n` bits, as an integer.),
    solution: ~S{Bitwise.bsl(elem(input, 0), elem(input, 1))},
    checks: [
      {~S({1, 4}), ~S{16}},
      {~S({3, 2}), ~S{12}},
      {~S({5, 0}), ~S{5}}
    ],
    tags: [:bitwise],
    difficulty: :easy
  },
  %{
    id: "numbers/bit-shr",
    prompt:
      ~S[`input` is a tuple `{a, n}`: an integer (possibly negative) and a non-negative shift count. Return `a` shifted RIGHT by `n` bits (arithmetic shift, preserving sign), as an integer.],
    solution: ~S{Bitwise.bsr(elem(input, 0), elem(input, 1))},
    checks: [
      {~S({255, 4}), ~S{15}},
      {~S({1, 3}), ~S{0}},
      {~S({-8, 1}), ~S{-4}}
    ],
    tags: [:bitwise],
    difficulty: :easy
  },
  %{
    id: "numbers/bit-not",
    prompt:
      ~S{`input` is an integer. Return its bitwise complement (NOT), using the two's complement semantics of unbounded Elixir integers.},
    solution: ~S{Bitwise.bnot(input)},
    checks: [
      {~S{0}, ~S{-1}},
      {~S{255}, ~S{-256}},
      {~S{-1}, ~S{0}}
    ],
    tags: [:bitwise, :gotcha],
    difficulty: :hard
  },

  # ------------------------------------------------------------------ Range

  %{
    id: "numbers/range-to-list",
    prompt: ~S{`input` is a range. Return the list of all its elements, in range order.},
    solution: ~S{Enum.to_list(input)},
    checks: [
      {~S{1..5}, ~S{[1, 2, 3, 4, 5]}},
      {~S{1..10//3}, ~S{[1, 4, 7, 10]}},
      {~S{5..5}, ~S{[5]}}
    ],
    tags: [:range],
    difficulty: :easy
  },
  %{
    id: "numbers/range-step-odd",
    prompt:
      ~S{`input` is a positive integer. Return the list of odd numbers from 1 up to `input`, inclusive, in ascending order.},
    solution: ~S{Enum.to_list(1..input//2)},
    checks: [
      {~S{10}, ~S{[1, 3, 5, 7, 9]}},
      {~S{1}, ~S{[1]}},
      {~S{2}, ~S{[1]}}
    ],
    tags: [:range],
    difficulty: :medium
  },
  %{
    id: "numbers/range-descending",
    prompt:
      ~S{`input` is a positive integer `n`. Return the list `[n, n-1, ..., 2, 1]` counting down to 1.},
    solution: ~S{Enum.to_list(input..1//-1)},
    checks: [
      {~S{5}, ~S{[5, 4, 3, 2, 1]}},
      {~S{1}, ~S{[1]}}
    ],
    tags: [:range, :drift],
    difficulty: :medium
  },
  %{
    id: "numbers/range-size",
    prompt:
      ~S{`input` is a range (it may have a step other than 1, and may be descending). Return the number of elements it contains, as an integer.},
    solution: ~S{Range.size(input)},
    checks: [
      {~S{1..10//3}, ~S{4}},
      {~S{10..1//-2}, ~S{5}},
      {~S{5..5}, ~S{1}}
    ],
    tags: [:range],
    difficulty: :medium
  },
  %{
    id: "numbers/range-membership",
    prompt:
      ~S[`input` is a tuple `{n, range}` of an integer and a range. Return the boolean of whether `n` is an ELEMENT of the range (for stepped ranges, only values actually on the step are elements).],
    solution: ~S(case input do {n, range} -> n in range end),
    checks: [
      {~S({5, 1..10}), ~S{true}},
      {~S({4, 1..10//2}), ~S{false}},
      {~S({11, 1..10}), ~S{false}}
    ],
    tags: [:range],
    difficulty: :medium
  },
  %{
    id: "numbers/range-step-of",
    prompt: ~S{`input` is a range. Return its step as an integer.},
    solution: ~S{case input do _.._//step -> step end},
    checks: [
      {~S{1..10//2}, ~S{2}},
      {~S{10..1//-1}, ~S{-1}},
      {~S{1..5}, ~S{1}}
    ],
    tags: [:range],
    difficulty: :hard
  },
  %{
    id: "numbers/range-sum",
    prompt: ~S{`input` is a range of integers. Return the sum of all its elements as an integer.},
    solution: ~S{Enum.sum(input)},
    checks: [
      {~S{1..100}, ~S{5050}},
      {~S{5..5}, ~S{5}},
      {~S{1..10//3}, ~S{22}}
    ],
    tags: [:range],
    difficulty: :easy
  },
  %{
    id: "numbers/range-first-last",
    prompt:
      ~S[`input` is a range. Return the tuple `{first, last}` of its `first` and `last` fields (for stepped ranges `last` is the declared bound, whether or not it is an element).],
    solution: ~S({input.first, input.last}),
    checks: [
      {~S{1..10//2}, ~S({1, 10})},
      {~S{5..5}, ~S({5, 5})}
    ],
    tags: [:range],
    difficulty: :easy
  },

  # --------------------------------------------------------- Erlang interop

  %{
    id: "numbers/erl-sqrt",
    prompt: ~S{`input` is a non-negative number. Return its square root as a float.},
    solution: ~S{:math.sqrt(input)},
    checks: [
      {~S{4}, ~S{2.0}},
      {~S{2.25}, ~S{1.5}},
      {~S{0}, ~S{0.0}}
    ],
    tags: [:erlang, :float],
    difficulty: :easy
  },
  %{
    id: "numbers/erl-pi-area",
    prompt:
      ~S{`input` is a number: the radius of a circle. Return the circle's area (pi times radius squared) as a float, using the standard library's full-precision value of pi.},
    solution: ~S{:math.pi() * input * input},
    checks: [
      {~S{1}, ~S{3.141592653589793}},
      {~S{2}, ~S{12.566370614359172}},
      {~S{0}, ~S{0.0}}
    ],
    tags: [:erlang, :float],
    difficulty: :easy
  },
  %{
    id: "numbers/erl-pow-float",
    prompt:
      ~S[`input` is a tuple `{base, exp}` of integers with `exp >= 0`. Return `base` raised to the power `exp` as a FLOAT (e.g. `1024.0`, not the integer `1024`).],
    solution: ~S[case input do {b, e} -> :math.pow(b, e) end],
    checks: [
      {~S({2, 10}), ~S{1024.0}},
      {~S({5, 0}), ~S{1.0}},
      {~S({3, 3}), ~S{27.0}}
    ],
    tags: [:erlang, :gotcha],
    difficulty: :medium
  },
  %{
    id: "numbers/erl-term-roundtrip",
    prompt:
      ~S{`input` is a binary produced by Erlang's external term format serialization (`:erlang.term_to_binary/1`). Return the original Elixir term it encodes.},
    solution: ~S{:erlang.binary_to_term(input)},
    checks: [
      {~S<:erlang.term_to_binary({:ok, [1, 2]})>, ~S({:ok, [1, 2]})},
      {~S[:erlang.term_to_binary(%{a: 1})], ~S(%{a: 1})},
      {~S{:erlang.term_to_binary([])}, ~S{[]}}
    ],
    tags: [:erlang],
    difficulty: :medium
  },
  %{
    id: "numbers/erl-lists-reverse",
    prompt: ~S{`input` is a list. Return the same elements in reverse order as a list.},
    solution: ~S{:lists.reverse(input)},
    checks: [
      {~S{[1, 2, 3]}, ~S{[3, 2, 1]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:erlang],
    difficulty: :easy
  },
  %{
    id: "numbers/erl-queue-front",
    prompt:
      ~S{`input` is a non-empty Erlang queue (an opaque `:queue` term). Return its FRONT element — the one that would be dequeued first.},
    solution: ~S{:queue.get(input)},
    checks: [
      {~S{:queue.from_list([1, 2, 3])}, ~S{1}},
      {~S{:queue.in(9, :queue.from_list([5]))}, ~S{5}}
    ],
    tags: [:erlang],
    difficulty: :hard
  },
  %{
    id: "numbers/erl-queue-in",
    prompt:
      ~S{`input` is an Erlang queue (an opaque `:queue` term, possibly empty). Return a LIST of the queue's elements in queue order after inserting the integer `99` at the rear.},
    solution: ~S{:queue.to_list(:queue.in(99, input))},
    checks: [
      {~S{:queue.from_list([1, 2])}, ~S{[1, 2, 99]}},
      {~S{:queue.new()}, ~S{[99]}}
    ],
    tags: [:erlang],
    difficulty: :medium
  },
  %{
    id: "numbers/erl-sha256-hex",
    prompt:
      ~S{`input` is a binary. Return its SHA-256 digest encoded as an UPPERCASE hexadecimal string.},
    solution: ~S{:crypto.hash(:sha256, input) |> Base.encode16()},
    checks: [
      {~S{"x"}, ~S{"2D711642B726B04401627CA9FBAC32F5C8530FB1903CC4DB02258717921A4881"}},
      {~S{""}, ~S{"E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"}}
    ],
    tags: [:erlang],
    difficulty: :medium
  }
]
