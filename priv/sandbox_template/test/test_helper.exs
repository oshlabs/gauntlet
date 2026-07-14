Code.require_file("support/gauntlet_json_formatter.exs", __DIR__)

formatters =
  if System.get_env("GAUNTLET_RESULTS_FILE") do
    [ExUnit.CLIFormatter, GauntletJsonFormatter]
  else
    [ExUnit.CLIFormatter]
  end

ExUnit.start(formatters: formatters)
