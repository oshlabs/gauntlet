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
    # Reasoning model: server thinks before answering; the reasoning arrives
    # in a separate field which ReqLLM maps to thinking content.
    reasoning: %{expected: true},
    # 32K tokens at ~28.5 tok/s needs generous headroom.
    request_timeout_ms: 1_800_000
  }
}
