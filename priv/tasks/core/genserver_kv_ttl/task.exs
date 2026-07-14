%{
  id: "core/genserver_kv_ttl",
  dimension: :generation,
  type: :write_code,
  difficulty: :hard,
  tags: [:curated, :otp, :genserver],
  module_name: "TtlStore",
  timeout_ms: 90_000,
  weight: 2.0
}
