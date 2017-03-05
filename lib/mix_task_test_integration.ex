defmodule Mix.Tasks.Test.Integration do
  use Mix.Task

  @shortdoc "Run the integration tests"

  def run(_) do
    Mix.Task.run(:cmd, ["MIX_ENV=integration_test mix test --only \"integration\""])
  end
end
