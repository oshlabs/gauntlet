# Named suites: which task packs run and how dimensions weigh into the
# composite score. The suite hash covers task content only, so editing
# weights does not invalidate cross-run comparison of raw dimension scores.
%{
  "default" => %{
    packs: ["core", "exercism"],
    weights: %{generation: 0.35, debugging: 0.25, comprehension: 0.20, quality: 0.20}
  },
  "core" => %{
    packs: ["core"],
    weights: %{generation: 0.35, debugging: 0.25, comprehension: 0.20, quality: 0.20}
  },
  "smoke" => %{
    packs: ["exercism"],
    weights: %{generation: 1.0}
  }
}
