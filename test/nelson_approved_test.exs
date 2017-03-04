defmodule NelsonApprovedTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.KeyValue
  alias NelsonApproved.Repo
  alias NelsonApproved.Food

  setup(context) do
    approved = Map.get(context, :approved, [])
    not_approved = Map.get(context, :not_approved, [])

    Enum.each(approved, &Repo.insert!(%Food{name: &1, approved: true}))
    Enum.each(not_approved, &Repo.insert!(%Food{name: &1, approved: false}))
  end

  @tag approved:     ["carrot"]
  @tag not_approved: ["pizza"]
  test "in repo => convert value" do
    assert :approved     == NelsonApproved.approved? "carrot"
    assert :not_approved == NelsonApproved.approved? "pizza"
  end

  test "closest_match" do
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili"])
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili", "pasta"])
  end

  @tag approved: ["carrot"]
  test "ignore case and whitespaces" do
    assert :approved == NelsonApproved.approved? "cArrOt"
    assert :approved == NelsonApproved.approved? "   cArrOt   "
  end

  describe "Not in Database: Ask AI =>" do
    test "approved" do
      set_call_counter 10
      set_mock_probability_processed_food 0.1
      assert :approved == NelsonApproved.approved? "carrot"
    end

    test "not approved" do
      set_call_counter 10
      set_mock_probability_processed_food 0.9
      assert :not_approved == NelsonApproved.approved? "carrot"
    end

    test "still unknown" do
      set_call_counter 10
      set_mock_probability_processed_food 0.7
      assert :unknown == NelsonApproved.approved? "carrot"
    end

    test "too many calls" do
      set_call_counter 6000
      set_mock_probability_processed_food 0.7
      assert :unknown == NelsonApproved.approved? "carrot"
    end

    def set_mock_probability_processed_food(val) do
      send self(), val
    end

    defp set_call_counter(counter) do
      %KeyValue{}
      |> KeyValue.changeset(%{key: "CALL_COUNTER", value: counter})
      |> Repo.insert!
    end
  end


end
