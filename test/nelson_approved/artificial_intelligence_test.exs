defmodule NelsonApproved.ArtificialIntelligenceTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.Repo
  alias NelsonApproved.KeyValue
  alias NelsonApproved.ArtificialIntelligence

  describe "Limit number of calls to API:" do
    test "too many calls " do
      # Limit is hardcoded in ArtificialIntelligence module
      set_call_counter 6000
      assert :too_many_calls = ArtificialIntelligence.approved?("whatever")
    end

    test "increase number of calls" do
      # Given: 10 calls where already made
      set_call_counter 10

      # When: Calling a eleventh time
      ArtificialIntelligence.approved?("whatever")

      # Then: Call counter has been incremented to 11
      assert 11 == get_call_counter()
    end
  end

  defp set_call_counter(counter) do
    %KeyValue{}
    |> KeyValue.changeset(%{key: "CALL_COUNTER", value: counter})
    |> Repo.insert!
  end
  defp get_call_counter do
    KeyValue
    |> Repo.get_by!(%{key: "CALL_COUNTER"})
    |> Map.get(:value)
  end
end
