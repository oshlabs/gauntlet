%{
  id: "core/supervised_worker",
  dimension: :generation,
  type: :write_code,
  difficulty: :hard,
  tags: [:curated, :otp, :supervisor],
  module_name: "Watchdog",
  timeout_ms: 90_000,
  weight: 2.0
}
