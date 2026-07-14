# Gauntlet model registry. Trusted repo content, evaluated with Code.eval_file.
# Each entry becomes a %Gauntlet.Model{}; see that module for field docs.
%{
  "deepseek-v4-flash" => %{
    model_spec: "openai:deepseek-v4-flash",
    base_url: "http://172.31.0.100:8000/v1",
    api_key_env: "GAUNTLET_API_KEY",
    api_key_default: "unused",
    max_concurrency: 8,
    max_tokens: 32_768,
    temperature: 0.0,
    # Reasoning is per-request on this server: without :reasoning_effort in
    # the request, thinking is DISABLED (reasoning field comes back null).
    # Valid: :none | :minimal | :low | :medium | :high | :xhigh — the
    # server also accepts "max" but req_llm's option schema stops at :xhigh.
    # nil sends nothing; override per run with `mix gauntlet.run --reasoning high`.
    reasoning_effort: nil,
    # When thinking IS enabled, the reasoning arrives in a separate field
    # which ReqLLM maps to thinking content (recorded, never parsed for code).
    reasoning: %{expected: true},
    # 32K tokens at ~28.5 tok/s needs generous headroom.
    request_timeout_ms: 1_800_000
  }
}
