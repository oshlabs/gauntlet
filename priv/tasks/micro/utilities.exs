# Micro items: stdlib utility modules — JSON (built-in since 1.18), Base,
# URI, Path (pure functions only), IO data / inspect, Version, OptionParser.
# All outputs verified against Elixir 1.19; no filesystem or cwd dependence.
#
# Sigil delimiters do not nest, so strings containing braces use ~S|...|
# (or ~S/.../ when they also contain pipes); brace-free strings use ~S{...}.

[
  # ── JSON (built-in module, tag :drift) ────────────────────────────────
  %{
    id: "utilities/json-encode-single-key-map",
    prompt:
      ~S{`input` is a map with at most one entry, whose key is a string and whose value is an integer. Return its JSON encoding as a string, using the JSON module that ships with Elixir.},
    solution: ~S{JSON.encode!(input)},
    checks: [
      {~S|%{"a" => 1}|, ~S|~S({"a":1})|},
      {~S|%{}|, ~S|"{}"|}
    ],
    tags: [:json, :drift],
    difficulty: :easy
  },
  %{
    id: "utilities/json-encode-list",
    prompt:
      ~S{`input` is a list containing integers, strings, and possibly nil values. Return its JSON encoding as a string (nil must appear as null).},
    solution: ~S{JSON.encode!(input)},
    checks: [
      {~S{[1, "two", nil]}, ~S{~S([1,"two",null])}},
      {~S{[]}, ~S{"[]"}}
    ],
    tags: [:json, :drift],
    difficulty: :easy
  },
  %{
    id: "utilities/json-decode-string-key-access",
    prompt:
      ~S{`input` is a JSON string encoding an object that has a key named "a". Decode it with Elixir's built-in JSON support and return the value stored under that key (return nil when the JSON value is null).},
    solution: ~S{JSON.decode!(input)["a"]},
    checks: [
      {~S|~S({"a": 5})|, ~S{5}},
      {~S|~S({"a": null})|, ~S{nil}}
    ],
    tags: [:json, :drift],
    difficulty: :hard
  },
  %{
    id: "utilities/json-decode-ok-tuple",
    prompt:
      ~S{`input` is a string containing a valid JSON array of integers. Decode it with the non-raising built-in JSON decoder and return the full result tuple it produces.},
    solution: ~S{JSON.decode(input)},
    checks: [
      {~S{"[1, 2, 3]"}, ~S|{:ok, [1, 2, 3]}|},
      {~S{"[]"}, ~S|{:ok, []}|}
    ],
    tags: [:json, :drift],
    difficulty: :easy
  },
  %{
    id: "utilities/json-decode-error-detect",
    prompt:
      ~S{`input` is a string that may or may not be valid JSON. Using Elixir's built-in JSON module, return the boolean true exactly when decoding `input` fails, and false when it succeeds.},
    solution: ~S|match?({:error, _}, JSON.decode(input))|,
    checks: [
      {~S|"{oops"|, ~S{true}},
      {~S{"[1]"}, ~S{false}},
      {~S{""}, ~S{true}}
    ],
    tags: [:json, :drift],
    difficulty: :medium
  },
  %{
    id: "utilities/json-encode-atom",
    prompt:
      ~S{`input` is an atom (possibly nil). Return its JSON encoding as a string, using the JSON module that ships with Elixir.},
    solution: ~S{JSON.encode!(input)},
    checks: [
      {~S{:hello}, ~S{~S("hello")}},
      {~S{nil}, ~S{"null"}}
    ],
    tags: [:json, :drift],
    difficulty: :medium
  },
  %{
    id: "utilities/json-encode-nil-value",
    prompt:
      ~S{`input` is a map with exactly one entry: a string key whose value is either an integer or nil. Return its JSON encoding as a string.},
    solution: ~S{JSON.encode!(input)},
    checks: [
      {~S|%{"a" => nil}|, ~S|~S({"a":null})|},
      {~S|%{"a" => 1}|, ~S|~S({"a":1})|}
    ],
    tags: [:json, :drift],
    difficulty: :easy
  },
  %{
    id: "utilities/json-keyword-not-encodable",
    prompt:
      ~S{`input` is a keyword list such as [a: 1] (possibly empty). Encode it directly with Elixir's built-in JSON.encode!/1 and return the result — do not convert or preprocess `input` in any way first.},
    solution: ~S{JSON.encode!(input)},
    checks: [
      {~S{[]}, ~S{"[]"}}
    ],
    raw_checks: [
      ~S{assert_raise Protocol.UndefinedError, fn -> Micro.solve(a: 1) end},
      ~S{assert_raise Protocol.UndefinedError, fn -> Micro.solve(verbose: true, depth: 2) end}
    ],
    tags: [:json, :drift],
    difficulty: :hard
  },
  %{
    id: "utilities/json-roundtrip-nested",
    prompt:
      ~S{`input` is a map with string keys whose values are integers, strings, or lists of those. Encode it to JSON and decode it straight back using Elixir's built-in JSON module; return the decoded map.},
    solution: ~S{input |> JSON.encode!() |> JSON.decode!()},
    checks: [
      {~S|%{"a" => [1, 2], "b" => "x"}|, ~S|%{"a" => [1, 2], "b" => "x"}|},
      {~S|%{}|, ~S|%{}|}
    ],
    tags: [:json, :drift],
    difficulty: :easy
  },
  %{
    id: "utilities/json-encode-to-iodata",
    prompt:
      ~S{`input` is a list of integers. Encode it to JSON iodata with the built-in JSON.encode_to_iodata!/1 and return that iodata flattened into a single binary string.},
    solution: ~S{input |> JSON.encode_to_iodata!() |> IO.iodata_to_binary()},
    checks: [
      {~S{[1, 2]}, ~S{"[1,2]"}},
      {~S{[]}, ~S{"[]"}}
    ],
    tags: [:json, :drift],
    difficulty: :easy
  },
  %{
    id: "utilities/json-decode-nested",
    prompt:
      ~S{`input` is a JSON string encoding an object whose values may include nested arrays, nested objects, and null. Decode it with the built-in JSON module and return the resulting Elixir term (objects become maps with string keys, null becomes nil).},
    solution: ~S{JSON.decode!(input)},
    checks: [
      {~S|~S({"a": [1, {"b": null}]})|, ~S|%{"a" => [1, %{"b" => nil}]}|},
      {~S|~S({})|, ~S|%{}|}
    ],
    tags: [:json, :drift],
    difficulty: :medium
  },
  %{
    id: "utilities/json-trap-builtin",
    prompt:
      ~S{Using only what Elixir ships with — no third-party packages of any kind — decode `input`, a string containing a JSON object, into a map and return it.},
    solution: ~S{JSON.decode!(input)},
    checks: [
      {~S|~S({"x": 1})|, ~S|%{"x" => 1}|},
      {~S|~S({})|, ~S|%{}|}
    ],
    tags: [:json, :drift, :trap],
    difficulty: :medium
  },

  # ── Base ──────────────────────────────────────────────────────────────
  %{
    id: "utilities/base-encode16-default",
    prompt:
      ~S{`input` is a binary. Return its base-16 (hexadecimal) encoding as an uppercase string.},
    solution: ~S{Base.encode16(input)},
    checks: [
      {~S{<<171, 205>>}, ~S{"ABCD"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:base],
    difficulty: :medium
  },
  %{
    id: "utilities/base-decode16-tuple",
    prompt:
      ~S|`input` is a string that may be a valid uppercase base-16 encoding. Decode it without raising: return {:ok, binary} on success and :error otherwise.|,
    solution: ~S{Base.decode16(input)},
    checks: [
      {~S{"4142"}, ~S|{:ok, "AB"}|},
      {~S{"zz"}, ~S{:error}}
    ],
    tags: [:base],
    difficulty: :easy
  },
  %{
    id: "utilities/base-decode16-mixed",
    prompt:
      ~S{`input` is a base-16 string that may freely mix upper- and lowercase hex digits. Decode it to the raw binary it represents (invalid input may raise).},
    solution: ~S{Base.decode16!(input, case: :mixed)},
    checks: [
      {~S{"6A6b"}, ~S{"jk"}},
      {~S{"616263"}, ~S{"abc"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:base],
    difficulty: :hard
  },
  %{
    id: "utilities/base-encode64",
    prompt:
      ~S{`input` is a binary. Return its standard Base64 encoding as a string, including any trailing padding.},
    solution: ~S{Base.encode64(input)},
    checks: [
      {~S{"ab"}, ~S{"YWI="}},
      {~S{""}, ~S{""}}
    ],
    tags: [:base],
    difficulty: :easy
  },
  %{
    id: "utilities/base-encode64-nopad",
    prompt:
      ~S{`input` is a binary. Return its standard Base64 encoding as a string with no trailing padding characters.},
    solution: ~S{Base.encode64(input, padding: false)},
    checks: [
      {~S{"ab"}, ~S{"YWI"}},
      {~S{"abc"}, ~S{"YWJj"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:base],
    difficulty: :medium
  },
  %{
    id: "utilities/base-url-encode64",
    prompt:
      ~S{`input` is a binary. Return its URL-safe Base64 encoding as a string — the alphabet that uses "-" and "_" instead of "+" and "/" — with padding kept.},
    solution: ~S{Base.url_encode64(input)},
    checks: [
      {~S{<<255, 255, 254>>}, ~S{"___-"}},
      {~S{"abc"}, ~S{"YWJj"}}
    ],
    tags: [:base],
    difficulty: :medium
  },
  %{
    id: "utilities/base-decode64-tuple",
    prompt:
      ~S|`input` is a string. Attempt standard Base64 decoding without raising: return {:ok, binary} on success and :error on invalid input.|,
    solution: ~S{Base.decode64(input)},
    checks: [
      {~S{"YWJj"}, ~S|{:ok, "abc"}|},
      {~S{"!!"}, ~S{:error}},
      {~S{""}, ~S|{:ok, ""}|}
    ],
    tags: [:base],
    difficulty: :easy
  },
  %{
    id: "utilities/base-decode64-bang",
    prompt:
      ~S{`input` is a string of standard, padded Base64. Decode it to the raw binary; invalid input must raise an ArgumentError.},
    solution: ~S{Base.decode64!(input)},
    checks: [
      {~S{"YWJj"}, ~S{"abc"}},
      {~S{""}, ~S{""}}
    ],
    raw_checks: [
      ~S{assert_raise ArgumentError, fn -> Micro.solve("!!") end}
    ],
    tags: [:base],
    difficulty: :easy
  },
  %{
    id: "utilities/base-decode64-nopad",
    prompt:
      ~S{`input` is a standard Base64 string that was encoded WITHOUT trailing padding. Decode it to the raw binary it represents (invalid input may raise).},
    solution: ~S{Base.decode64!(input, padding: false)},
    checks: [
      {~S{"YWI"}, ~S{"ab"}},
      {~S{"YWJj"}, ~S{"abc"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:base],
    difficulty: :hard
  },
  %{
    id: "utilities/base-trap-hex",
    prompt:
      ~S{`input` is a binary. Using only Elixir's standard library, return its lowercase hexadecimal representation as a string.},
    solution: ~S{Base.encode16(input, case: :lower)},
    checks: [
      {~S{"abc"}, ~S{"616263"}},
      {~S{<<255>>}, ~S{"ff"}},
      {~S{""}, ~S{""}}
    ],
    tags: [:base, :trap],
    difficulty: :medium
  },

  # ── URI ───────────────────────────────────────────────────────────────
  %{
    id: "utilities/uri-parse-host",
    prompt:
      ~S{`input` is a URL string. Parse it and return the host part as a string, or nil when the URL has no host.},
    solution: ~S{URI.parse(input).host},
    checks: [
      {~S{"https://example.com/x"}, ~S{"example.com"}},
      {~S{"/just/path"}, ~S{nil}}
    ],
    tags: [:uri],
    difficulty: :easy
  },
  %{
    id: "utilities/uri-default-port",
    prompt:
      ~S{`input` is a URL string. Parse it and return the port as an integer. When the URL does not state a port explicitly, return the default port for its scheme.},
    solution: ~S{URI.parse(input).port},
    checks: [
      {~S{"http://example.com"}, ~S{80}},
      {~S{"https://example.com"}, ~S{443}},
      {~S{"https://example.com:8080"}, ~S{8080}}
    ],
    tags: [:uri],
    difficulty: :medium
  },
  %{
    id: "utilities/uri-path-query",
    prompt:
      ~S|`input` is a URL string. Parse it and return the two-element tuple {path, query} taken straight from the parsed URI struct (each element is a string, or nil when absent).|,
    solution: ~S/input |> URI.parse() |> then(&{&1.path, &1.query})/,
    checks: [
      {~S{"https://example.com/docs?q=elixir"}, ~S|{"/docs", "q=elixir"}|},
      {~S{"https://example.com"}, ~S|{nil, nil}|}
    ],
    tags: [:uri],
    difficulty: :medium
  },
  %{
    id: "utilities/uri-decode-query",
    prompt:
      ~S{`input` is a URL query string such as "a=1&b=two". Parse it into a map of string keys to string values (the empty string yields an empty map).},
    solution: ~S{URI.decode_query(input)},
    checks: [
      {~S{"a=1&b=two"}, ~S|%{"a" => "1", "b" => "two"}|},
      {~S{""}, ~S|%{}|}
    ],
    tags: [:uri, :trap],
    difficulty: :easy
  },
  %{
    id: "utilities/uri-encode-query-single",
    prompt:
      ~S{`input` is a map with at most one entry (string key, string value). Encode it as an application/x-www-form-urlencoded query string, exactly as browsers submit forms.},
    solution: ~S{URI.encode_query(input)},
    checks: [
      {~S|%{"q" => "hello world"}|, ~S{"q=hello+world"}},
      {~S|%{}|, ~S{""}}
    ],
    tags: [:uri],
    difficulty: :hard
  },
  %{
    id: "utilities/uri-encode-query-roundtrip",
    prompt:
      ~S{`input` is a map of string keys to string values. Encode it into a query string and immediately decode that string back into a map; return the decoded map (it must equal `input`).},
    solution: ~S{input |> URI.encode_query() |> URI.decode_query()},
    checks: [
      {~S|%{"a" => "1", "b" => "2"}|, ~S|%{"a" => "1", "b" => "2"}|},
      {~S|%{}|, ~S|%{}|}
    ],
    tags: [:uri],
    difficulty: :easy
  },
  %{
    id: "utilities/uri-percent-encode",
    prompt:
      ~S{`input` is a string. Percent-encode it for use inside a URL, so that a space becomes "%20"; characters that need no escaping stay as they are. Return the encoded string.},
    solution: ~S{URI.encode(input)},
    checks: [
      {~S{"hello world"}, ~S{"hello%20world"}},
      {~S{"safe"}, ~S{"safe"}}
    ],
    tags: [:uri],
    difficulty: :easy
  },
  %{
    id: "utilities/uri-percent-decode",
    prompt:
      ~S{`input` is a percent-encoded URL string. Decode every percent escape and return the plain string.},
    solution: ~S{URI.decode(input)},
    checks: [
      {~S{"hello%20world%21"}, ~S{"hello world!"}},
      {~S{"plain"}, ~S{"plain"}}
    ],
    tags: [:uri],
    difficulty: :easy
  },
  %{
    id: "utilities/uri-merge",
    prompt:
      ~S|`input` is a two-element tuple {base, ref} of strings, where base is an absolute URL. Merge the reference against the base per RFC 3986 (a relative reference replaces the last path segment; a reference starting with "/" replaces the whole path) and return the merged URL as a string.|,
    solution: ~S{URI.merge(elem(input, 0), elem(input, 1)) |> to_string()},
    checks: [
      {~S|{"https://example.com/foo/bar", "baz"}|, ~S{"https://example.com/foo/baz"}},
      {~S|{"https://example.com/a/b", "/c"}|, ~S{"https://example.com/c"}}
    ],
    tags: [:uri],
    difficulty: :hard
  },
  %{
    id: "utilities/uri-new-validate",
    prompt:
      ~S{`input` is a string. Validate it with URI.new/1 (available since Elixir 1.13): return the boolean true when it produces an :ok tuple and false when it produces an :error tuple.},
    solution: ~S|match?({:ok, _}, URI.new(input))|,
    checks: [
      {~S{"https://example.com"}, ~S{true}},
      {~S{">bad<"}, ~S{false}}
    ],
    tags: [:uri],
    difficulty: :easy
  },

  # ── Path (pure functions only) ────────────────────────────────────────
  %{
    id: "utilities/path-join-list",
    prompt:
      ~S{`input` is a nonempty list of path segment strings. Join them into a single path string separated by "/".},
    solution: ~S{Path.join(input)},
    checks: [
      {~S{["usr", "local", "bin"]}, ~S{"usr/local/bin"}},
      {~S{["solo"]}, ~S{"solo"}}
    ],
    tags: [:path],
    difficulty: :easy
  },
  %{
    id: "utilities/path-join-two",
    prompt:
      ~S|`input` is a two-element tuple of path strings {left, right}. Join right onto left with a single separator between them and return the resulting path string.|,
    solution: ~S{Path.join(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"foo", "bar/baz"}|, ~S{"foo/bar/baz"}},
      {~S|{"/", "a"}|, ~S{"/a"}}
    ],
    tags: [:path],
    difficulty: :easy
  },
  %{
    id: "utilities/path-expand-base",
    prompt:
      ~S|`input` is a tuple {path, base} of strings where base is an absolute path. Expand path relative to base, resolving any "." and ".." segments; the result must not depend on the current working directory.|,
    solution: ~S{Path.expand(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"b/../c", "/a"}|, ~S{"/a/c"}},
      {~S|{"..", "/a/b"}|, ~S{"/a"}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-basename-ext",
    prompt:
      ~S{`input` is a path string. Return its last component with a trailing ".ex" extension stripped when present; components with any other extension must be returned intact.},
    solution: ~S{Path.basename(input, ".ex")},
    checks: [
      {~S{"/foo/bar.ex"}, ~S{"bar"}},
      {~S{"/foo/bar.txt"}, ~S{"bar.txt"}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-dirname",
    prompt:
      ~S{`input` is a path string. Return its directory part — everything except the last component. For a bare filename with no separator, return ".".},
    solution: ~S{Path.dirname(input)},
    checks: [
      {~S{"/foo/bar/baz.ex"}, ~S{"/foo/bar"}},
      {~S{"baz.ex"}, ~S{"."}}
    ],
    tags: [:path],
    difficulty: :easy
  },
  %{
    id: "utilities/path-extname",
    prompt:
      ~S{`input` is a path string. Return its file extension including the leading dot (only the last extension for names like "archive.tar.gz"), or "" when there is none.},
    solution: ~S{Path.extname(input)},
    checks: [
      {~S{"/foo/archive.tar.gz"}, ~S{".gz"}},
      {~S{"noext"}, ~S{""}}
    ],
    tags: [:path],
    difficulty: :easy
  },
  %{
    id: "utilities/path-extname-hidden",
    prompt:
      ~S{`input` is a path string that may name a Unix hidden file such as ".gitignore". Return the file extension exactly as Elixir's standard path API computes it: a name whose only dot is the leading one has NO extension.},
    solution: ~S{Path.extname(input)},
    checks: [
      {~S{".gitignore"}, ~S{""}},
      {~S{".config.toml"}, ~S{".toml"}},
      {~S{"dir/.profile"}, ~S{""}}
    ],
    tags: [:path],
    difficulty: :hard
  },
  %{
    id: "utilities/path-rootname",
    prompt:
      ~S{`input` is a path string. Return the path with its extension removed; a path without an extension is returned unchanged.},
    solution: ~S{Path.rootname(input)},
    checks: [
      {~S{"/foo/bar.ex"}, ~S{"/foo/bar"}},
      {~S{"noext"}, ~S{"noext"}}
    ],
    tags: [:path],
    difficulty: :easy
  },
  %{
    id: "utilities/path-rootname-ext",
    prompt:
      ~S|`input` is a tuple {path, ext} of strings. Remove ext from the end of path only when path actually ends in that extension; otherwise return path unchanged.|,
    solution: ~S{Path.rootname(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"bar.tar.gz", ".gz"}|, ~S{"bar.tar"}},
      {~S|{"bar.tar.gz", ".zip"}|, ~S{"bar.tar.gz"}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-split",
    prompt:
      ~S{`input` is a path string. Split it into all of its components and return them as a list of strings, using the standard path API (an empty path yields an empty list).},
    solution: ~S{Path.split(input)},
    checks: [
      {~S{"/usr/local/bin"}, ~S{["/", "usr", "local", "bin"]}},
      {~S{"rel/a"}, ~S{["rel", "a"]}},
      {~S{""}, ~S{[]}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-relative-to",
    prompt:
      ~S|`input` is a tuple {path, from} of absolute path strings. Return path rewritten relative to from when path lies inside from; when it does not, return path unchanged.|,
    solution: ~S{Path.relative_to(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"/usr/local/bin", "/usr"}|, ~S{"local/bin"}},
      {~S|{"/usr/local", "/opt"}|, ~S{"/usr/local"}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-absname-base",
    prompt:
      ~S|`input` is a tuple {path, base} of strings, base being absolute. Return path made absolute by prefixing base when path is relative; a path that is already absolute is returned as-is. Do not resolve "." or ".." segments.|,
    solution: ~S{Path.absname(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"foo", "/bar"}|, ~S{"/bar/foo"}},
      {~S|{"/foo", "/bar"}|, ~S{"/foo"}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-type",
    prompt:
      ~S{`input` is a path string. Classify it, returning the atom :absolute for absolute paths and :relative for relative ones.},
    solution: ~S{Path.type(input)},
    checks: [
      {~S{"/abs"}, ~S{:absolute}},
      {~S{"rel/x"}, ~S{:relative}}
    ],
    tags: [:path],
    difficulty: :medium
  },
  %{
    id: "utilities/path-trap-filename",
    prompt:
      ~S{`input` is a path string. Return just the file name portion — the final component after the last separator (a path with no separator is returned whole).},
    solution: ~S{Path.basename(input)},
    checks: [
      {~S{"/a/b/c.txt"}, ~S{"c.txt"}},
      {~S{"c.txt"}, ~S{"c.txt"}}
    ],
    tags: [:path, :trap],
    difficulty: :easy
  },

  # ── IO data & inspect ─────────────────────────────────────────────────
  %{
    id: "utilities/iodata-to-binary",
    prompt:
      ~S{`input` is iodata: arbitrarily nested lists containing binaries and byte-valued integers. Flatten it into a single binary string.},
    solution: ~S{IO.iodata_to_binary(input)},
    checks: [
      {~S{["he", [108, ["lo"]]]}, ~S{"hello"}},
      {~S{[]}, ~S{""}}
    ],
    tags: [:iodata],
    difficulty: :easy
  },
  %{
    id: "utilities/iodata-length",
    prompt:
      ~S{`input` is iodata (nested lists of binaries and byte integers). Return its total size in bytes as an integer.},
    solution: ~S{IO.iodata_length(input)},
    checks: [
      {~S{["ab", [?c, "de"]]}, ~S{5}},
      {~S{[[], "", [[]]]}, ~S{0}}
    ],
    tags: [:iodata],
    difficulty: :medium
  },
  %{
    id: "utilities/iodata-improper",
    prompt:
      ~S{`input` is valid iodata that may be an IMPROPER list whose tail is a binary, e.g. ["ab" | "cd"]. Convert it into a single binary string (a plain list-walking approach will crash on the improper tail).},
    solution: ~S{IO.iodata_to_binary(input)},
    checks: [
      {~S{["ab" | "cd"]}, ~S{"abcd"}},
      {~S{["x", [?y | "z"]]}, ~S{"xyz"}},
      {~S{[]}, ~S{""}}
    ],
    tags: [:iodata],
    difficulty: :hard
  },
  %{
    id: "utilities/inspect-limit",
    prompt:
      ~S{`input` is a list of integers. Return the inspect string of the list restricted to showing at most 3 elements; longer lists must end with the standard "..." truncation marker.},
    solution: ~S{inspect(input, limit: 3)},
    checks: [
      {~S{[1, 2, 3, 4, 5]}, ~S{"[1, 2, 3, ...]"}},
      {~S{[1, 2]}, ~S{"[1, 2]"}}
    ],
    tags: [:inspect],
    difficulty: :medium
  },
  %{
    id: "utilities/inspect-charlists-as-lists",
    prompt:
      ~S{`input` is a list of integers. Return its inspect string forced to render as a plain list of numbers, even when every integer happens to be a printable character code.},
    solution: ~S{inspect(input, charlists: :as_lists)},
    checks: [
      {~S{[97, 98, 99]}, ~S{"[97, 98, 99]"}},
      {~S{[1, 2]}, ~S{"[1, 2]"}}
    ],
    tags: [:inspect],
    difficulty: :medium
  },
  %{
    id: "utilities/inspect-binaries-as-binaries",
    prompt:
      ~S{`input` is a string (a binary). Return its inspect string forced to render as a raw byte sequence in <<...>> notation instead of a double-quoted string.},
    solution: ~S{inspect(input, binaries: :as_binaries)},
    checks: [
      {~S{"abc"}, ~S{"<<97, 98, 99>>"}},
      {~S{""}, ~S{"<<>>"}}
    ],
    tags: [:inspect],
    difficulty: :medium
  },
  %{
    id: "utilities/inspect-atom",
    prompt:
      ~S{`input` is an atom. Return its inspect string — the way it would be written in Elixir source (note that nil, true and false have special renderings).},
    solution: ~S{inspect(input)},
    checks: [
      {~S{:ok}, ~S{":ok"}},
      {~S{nil}, ~S{"nil"}}
    ],
    tags: [:inspect],
    difficulty: :easy
  },
  %{
    id: "utilities/inspect-string",
    prompt:
      ~S{`input` is a string. Return its inspect string: the string wrapped in literal double-quote characters, as it would appear in Elixir source.},
    solution: ~S{inspect(input)},
    checks: [
      {~S{"s"}, ~S{~S("s")}},
      {~S{""}, ~S{~S("")}}
    ],
    tags: [:inspect],
    difficulty: :easy
  },

  # ── Version ───────────────────────────────────────────────────────────
  %{
    id: "utilities/version-parse-fields",
    prompt:
      ~S|`input` is a semantic version string like "1.2.3". Parse it and return the tuple {major, minor, patch} of three integers.|,
    solution: ~S/input |> Version.parse!() |> then(&{&1.major, &1.minor, &1.patch})/,
    checks: [
      {~S{"1.2.3"}, ~S|{1, 2, 3}|},
      {~S{"0.0.1"}, ~S|{0, 0, 1}|}
    ],
    tags: [:version],
    difficulty: :easy
  },
  %{
    id: "utilities/version-compare-semver",
    prompt:
      ~S|`input` is a two-element tuple of semantic version strings {v1, v2}. Compare them by SEMVER rules (numeric per component, not lexicographic) and return :lt, :eq or :gt.|,
    solution: ~S{Version.compare(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"1.2.3", "1.10.0"}|, ~S{:lt}},
      {~S|{"2.0.0", "2.0.0"}|, ~S{:eq}}
    ],
    tags: [:version],
    difficulty: :medium
  },
  %{
    id: "utilities/version-match-tilde-minor",
    prompt:
      ~S{`input` is a semantic version string. Return the boolean true when it satisfies the requirement "~> 2.0" and false otherwise.},
    solution: ~S{Version.match?(input, "~> 2.0")},
    checks: [
      {~S{"2.1.0"}, ~S{true}},
      {~S{"3.0.0"}, ~S{false}}
    ],
    tags: [:version],
    difficulty: :medium
  },
  %{
    id: "utilities/version-match-tilde-patch",
    prompt:
      ~S{`input` is a semantic version string. Return the boolean true when it satisfies the requirement "~> 2.1.0" and false otherwise.},
    solution: ~S{Version.match?(input, "~> 2.1.0")},
    checks: [
      {~S{"2.1.7"}, ~S{true}},
      {~S{"2.2.0"}, ~S{false}}
    ],
    tags: [:version],
    difficulty: :hard
  },
  %{
    id: "utilities/version-prerelease-lt",
    prompt:
      ~S|`input` is a two-element tuple of semantic version strings {v1, v2}, where either may carry a pre-release suffix like "-rc.1". Compare them under full semver precedence rules and return :lt, :eq or :gt.|,
    solution: ~S{Version.compare(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{"1.0.0-rc.1", "1.0.0"}|, ~S{:lt}},
      {~S|{"1.0.0-alpha", "1.0.0-beta"}|, ~S{:lt}}
    ],
    tags: [:version],
    difficulty: :hard
  },
  %{
    id: "utilities/version-pre-field",
    prompt:
      ~S{`input` is a semantic version string that may carry a pre-release suffix such as "1.2.3-rc.1". Parse it and return the pre-release segments as a list, exactly as the parsed struct stores them (numeric segments become integers; no pre-release yields an empty list).},
    solution: ~S{Version.parse!(input).pre},
    checks: [
      {~S{"1.2.3-rc.1"}, ~S{["rc", 1]}},
      {~S{"1.2.3"}, ~S{[]}}
    ],
    tags: [:version],
    difficulty: :hard
  },

  # ── OptionParser ──────────────────────────────────────────────────────
  %{
    id: "utilities/optionparser-parse-strict",
    prompt:
      ~S|`input` is a list of command-line argument strings. Parse it with a strict schema declaring one switch: --name of type :string. Return the full three-element result tuple {parsed, remaining_args, invalid}.|,
    solution: ~S{OptionParser.parse(input, strict: [name: :string])},
    checks: [
      {~S{["--name", "ana", "file.txt"]}, ~S|{[name: "ana"], ["file.txt"], []}|},
      {~S{[]}, ~S|{[], [], []}|}
    ],
    tags: [:optionparser],
    difficulty: :medium
  },
  %{
    id: "utilities/optionparser-parsed-only",
    prompt:
      ~S{`input` is a list of command-line argument strings. Parse it strictly with a single switch --name of type :string, and return ONLY the parsed options keyword list (the first element of the result).},
    solution: ~S{elem(OptionParser.parse(input, strict: [name: :string]), 0)},
    checks: [
      {~S{["--name", "ana"]}, ~S{[name: "ana"]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:optionparser],
    difficulty: :easy
  },
  %{
    id: "utilities/optionparser-boolean-negation",
    prompt:
      ~S{`input` is a list of command-line argument strings. Parse it strictly with a single switch --verbose of type :boolean and return only the parsed options keyword list. Boolean switches must also accept their negated "--no-" form.},
    solution: ~S{elem(OptionParser.parse(input, strict: [verbose: :boolean]), 0)},
    checks: [
      {~S{["--verbose"]}, ~S{[verbose: true]}},
      {~S{["--no-verbose"]}, ~S{[verbose: false]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:optionparser],
    difficulty: :hard
  },
  %{
    id: "utilities/optionparser-alias",
    prompt:
      ~S{`input` is a list of command-line argument strings. Parse it strictly with a switch --count of type :integer that is also reachable through the short alias -n. Return only the parsed options keyword list.},
    solution: ~S{elem(OptionParser.parse(input, strict: [count: :integer], aliases: [n: :count]), 0)},
    checks: [
      {~S{["-n", "3"]}, ~S{[count: 3]}},
      {~S{["--count", "7"]}, ~S{[count: 7]}}
    ],
    tags: [:optionparser],
    difficulty: :medium
  },
  %{
    id: "utilities/optionparser-integer-coerce",
    prompt:
      ~S{`input` is a list of command-line argument strings. Parse it strictly with a single switch --count of type :integer and return only the parsed options keyword list — the value must arrive as an actual integer, not a string.},
    solution: ~S{elem(OptionParser.parse(input, strict: [count: :integer]), 0)},
    checks: [
      {~S{["--count", "42"]}, ~S{[count: 42]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:optionparser],
    difficulty: :medium
  },
  %{
    id: "utilities/optionparser-invalid-part",
    prompt:
      ~S{`input` is a list of command-line argument strings. Parse it strictly with a single switch --good of type :string and return ONLY the invalid list (the third element of the result), which collects unknown or badly-typed switches as tuples.},
    solution: ~S{elem(OptionParser.parse(input, strict: [good: :string]), 2)},
    checks: [
      {~S{["--bad", "x"]}, ~S|[{"--bad", nil}]|},
      {~S{["--good", "y"]}, ~S{[]}}
    ],
    tags: [:optionparser],
    difficulty: :hard
  }
]
