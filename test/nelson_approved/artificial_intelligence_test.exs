defmodule NelsonApproved.ArtificialIntelligenceTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.Repo
  alias NelsonApproved.KeyValue
  alias NelsonApproved.ArtificialIntelligence

  describe "Ask AI:" do
    test "above approved threshold" do
      set_call_counter 10
      set_mock_ai_response 0.99
      assert ArtificialIntelligence.is_processed_food? "whatever"
    end

    test "below not approved threshold" do
      set_call_counter 10
      set_mock_ai_response 0.10
      refute ArtificialIntelligence.is_processed_food? "whatever"
    end

    test "in-between both threshold" do
      set_call_counter 10
      set_mock_ai_response 0.7
      assert :unknown == ArtificialIntelligence.is_processed_food? "whatever"
    end
  end

  def set_mock_ai_response(val) do
    send self(), val
  end

  describe "Limit number of calls to API:" do
    test "too many calls " do
      # Limit is hardcoded in ArtificialIntelligence module
      set_call_counter 6000
      assert :too_many_calls = ArtificialIntelligence.is_processed_food?("whatever")
    end

    test "increase number of calls" do
      # Given: 10 calls where already made
      set_call_counter 10
      set_mock_ai_response 1

      # When: Calling a eleventh time
      ArtificialIntelligence.is_processed_food?("whatever")

      # Then: Call counter has been incremented to 11
      assert 11 == get_call_counter()
    end

    test "call counter not set => set to 0 and increment" do
      set_mock_ai_response 1

      # When: Calling a eleventh time
      ArtificialIntelligence.is_processed_food?("whatever")

      # Then: Call counter has been incremented to 11
      assert 1 == get_call_counter()
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
