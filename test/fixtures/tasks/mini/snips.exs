[
  %{
    id: "snips/upcase",
    prompt: ~S{`input` is a string. Return it upcased.},
    solution: ~S{String.upcase(input)},
    checks: [{~S{"abc"}, ~S{"ABC"}}],
    tags: [:string]
  }
]
