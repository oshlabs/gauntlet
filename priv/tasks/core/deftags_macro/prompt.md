Write a macro module `Taggable`. A module that does `use Taggable, tags: [...]` gets a small tag vocabulary compiled into it.

    defmodule Article do
      use Taggable, tags: [:draft, :published, :archived]
    end

must generate, at compile time, in `Article`:

- `tags/0` — returns the tag list in declaration order: `[:draft, :published, :archived]`.
- One predicate per tag, named `<tag>?/1`, that tests list membership: `Article.draft?([:draft, :x])` → `true`; `Article.draft?([:x])` → `false`.
- `valid?/1` — true if every element of the given list is in the vocabulary: `Article.valid?([:draft])` → `true`; `Article.valid?([:draft, :bogus])` → `false`.

Requirements:

- The predicates must be real compiled functions (generated with the macro), not runtime lookups through a catch-all — `Article.__info__(:functions)` must list `draft?: 1`, `published?: 1`, `archived?: 1`.
- `use Taggable` without a `:tags` option, or with an empty list, must raise a `CompileError` or `ArgumentError` at compile time.
- Two modules using different vocabularies must not interfere.
