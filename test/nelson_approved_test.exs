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

  describe "In Database: =>" do
    @tag approved:     ["carrot"]
    @tag not_approved: ["pizza"]
    test "convert value" do
      assert_approved "carrot"
      assert_not_approved "pizza"
    end

    @tag approved: ["carrot"]
    test "ignore case and whitespaces" do
      assert_approved "cArrOt"
      assert_approved "   cArrOt   "
    end
  end

  describe "Not in Database: Ask AI =>" do
    test "approved" do
      set_call_counter 10
      set_mock_probability_processed_food 0.1
      assert_approved "carrot", true
    end

    test "not approved" do
      set_call_counter 10
      set_mock_probability_processed_food 0.9
      assert_not_approved "carrot", true
    end

    test "still unknown" do
      set_call_counter 10
      set_mock_probability_processed_food 0.7
      assert_unknown "carrot", true
    end

    test "too many calls" do
      set_call_counter 6000
      set_mock_probability_processed_food 0.7
      assert_unknown "carrot", true
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

  test "closest_match" do
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili"])
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili", "pasta"])
  end

  defp assert_approved(food, using_ai? \\ false) do
    assert %NelsonApproved.Response{approved?: :approved, using_ai?: ^using_ai?} = NelsonApproved.approved? food
  end
  defp assert_not_approved(food, using_ai? \\ false) do
    assert %NelsonApproved.Response{approved?: :not_approved, using_ai?: ^using_ai?} = NelsonApproved.approved? food
  end
  defp assert_unknown(food, using_ai?) do
    assert %NelsonApproved.Response{approved?: :unknown, using_ai?: ^using_ai?} = NelsonApproved.approved? food
  end


end
