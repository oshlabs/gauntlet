Write a module `ConfigValidator` that validates a server configuration map and returns a normalized struct.

Define a struct `ConfigValidator.Config` with fields `:host`, `:port`, `:tls`, `:tags`.

Implement `validate/1` taking a map with string keys and returning `{:ok, %ConfigValidator.Config{}}` or `{:error, reason}` — the **first** error in the field order below:

1. `"host"` — required; must be a non-empty string. Errors: `{:error, {:missing, :host}}` / `{:error, {:invalid, :host}}`.
2. `"port"` — optional, defaults to 4000. If present: an integer in 1..65535, or a string of digits that parses to such an integer (normalize to the integer). Error: `{:error, {:invalid, :port}}`.
3. `"tls"` — optional, defaults to `false`. If present: must be a boolean or the strings `"true"`/`"false"` (normalize to boolean). Error: `{:error, {:invalid, :tls}}`.
4. `"tags"` — optional, defaults to `[]`. If present: a list of non-empty strings, normalized to sorted unique atoms created with `String.to_atom/1`. Error: `{:error, {:invalid, :tags}}`.

Unknown keys in the input map are an error: `{:error, {:unknown_keys, keys}}` with `keys` the sorted list of offending string keys. Check this **before** the field checks.

Use idiomatic error composition (this is the kind of function `with/1` exists for).
