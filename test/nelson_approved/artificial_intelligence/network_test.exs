defmodule NelsonApproved.ArtificialIntelligence.NetworkTest do
  use ExUnit.Case
  alias NelsonApproved.ArtificialIntelligence.Network

  @tag timeout: 10_000
  @tag :skip
  test "Smoke test for network module" do
    valid = Network.semantic_relatedness("kebab", "processed food")
    invalid = Network.semantic_relatedness("", "processed food")

    assert is_number(valid)
    assert invalid == :error
  end


end
