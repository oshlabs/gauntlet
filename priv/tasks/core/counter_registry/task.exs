%{
  id: "core/counter_registry",
  dimension: :generation,
  type: :write_code,
  difficulty: :hard,
  tags: [:curated, :otp, :registry, :dynamic_supervisor],
  module_name: "CounterFarm",
  timeout_ms: 90_000,
  weight: 2.0
}
