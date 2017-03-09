defmodule NelsonApprovedTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.Repo
  alias NelsonApproved.Food
  alias NelsonApproved.AiCounterMock

  setup(context) do
    AiCounterMock.start_mock

    insert_food_if_not_nil(context[:approved], true)
    insert_food_if_not_nil(context[:not_approved], false)

    :ok
  end

  defp insert_food_if_not_nil(nil, _), do: :ignored
  defp insert_food_if_not_nil(food, approved), do: Repo.insert!(%Food{name: food, approved: approved})

  test "Not a food name" do
    assert_unknown "sadf"
  end

  describe "In User Database =>" do
    test "use database user value"
    test "ignore case and whitespaces"
    test "override nelson's approval"
  end

  describe "In Admin/Nelson Database: =>" do
    @tag approved:     "carrot"
    @tag not_approved: "pizza"
    test "use database value" do
      assert_approved "carrot"
      assert_not_approved "pizza"
    end

    @tag approved: "carrot"
    test "ignore case and whitespaces" do
      assert_approved "cArrOt"
      assert_approved "   cArrOt   "
    end
  end

  describe "Not in Database: Ask AI =>" do
    test "approved" do
      set_mock_probability_processed_food 0.1
      assert_approved "carrot", true
    end

    test "not approved" do
      set_mock_probability_processed_food 0.9
      assert_not_approved "carrot", true
    end

    test "still unknown" do
      set_mock_probability_processed_food 0.7
      assert_unknown "carrot", true
    end

    test "too many calls" do
      set_mock_probability_processed_food 0.7
      assert_unknown "carrot", true
    end

    def set_mock_probability_processed_food(val) do
      send self(), val
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
  defp assert_unknown(food, using_ai? \\ false) do
    assert %NelsonApproved.Response{approved?: :unknown, using_ai?: ^using_ai?} = NelsonApproved.approved? food
  end


end
