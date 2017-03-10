defmodule NelsonApprovedTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.AiCounterMock
  alias NelsonApproved.AiNetworkMock

  setup(context) do
    AiCounterMock.start_mock
    AiNetworkMock.start_mock()

    insert_food_if_not_nil(context[:approved], true)
    insert_food_if_not_nil(context[:not_approved], false)

    user = insert_user()
    insert_user_food_if_not_nil(user, context[:user_approved], true)
    insert_user_food_if_not_nil(user, context[:user_not_approved], false)

    %{user: user}
  end

  defp insert_food_if_not_nil(nil, _),         do: :ignored
  defp insert_food_if_not_nil(food, approved), do: insert_food(food, approved)
  defp insert_user_food_if_not_nil(_user, nil, _),         do: :ignored
  defp insert_user_food_if_not_nil(user, food, approved), do: insert_user_food(user, food, approved)

  test "Not a food name" do
    assert_unknown "sadf"
  end

  describe "In User Database =>" do
    @tag user_approved:     "carrot"
    @tag user_not_approved: "pizza"
    test "use database user value", %{user: user} do
      assert_approved     "carrot", user: user
      assert_not_approved "pizza", user: user
    end

    @tag user_approved: "carrot"
    test "ignore case and whitespaces", %{user: user} do
      assert_approved "cArrOt", user: user
      assert_approved "   cArrOt   ", user: user
    end

    @tag user_approved: "pizza"
    @tag not_approved:  "pizza"
    test "override nelson's approval", %{user: user} do
      assert_not_approved "pizza"
      assert_approved     "pizza", user: user
    end

    @tag user_approved: "pizza"
    @tag not_approved:  "pizza"
    test "in another user food db, ignore", %{user: user} do
      another_user = insert_user(username: "Another user")

      assert_approved     "pizza", user: user
      assert_not_approved "pizza", user: another_user
    end
  end

  describe "Not in User Database => Check Admin Database: =>" do
    @tag approved:     "carrot"
    @tag not_approved: "pizza"
    test "use database value", %{user: user} do
      assert_approved "carrot"
      assert_approved "carrot", user: user
      assert_not_approved "pizza"
      assert_not_approved "pizza", user: user
    end

    @tag approved: "carrot"
    test "ignore case and whitespaces", %{user: user} do
      assert_approved "cArrOt"
      assert_approved "cArrOt", user: user
      assert_approved "   cArrOt   "
      assert_approved "   cArrOt   ", user: user
    end
  end

  describe "Not in User/Admin Database => Ask AI =>" do
    test "approved", %{user: user} do
      set_mock_probability_processed_food 0.1
      assert_approved "carrot", using_ai?: true
      assert_approved "carrot", using_ai?: true, user: user
    end

    test "not approved", %{user: user} do
      set_mock_probability_processed_food 0.9
      assert_not_approved "carrot", using_ai?: true
      assert_not_approved "carrot", using_ai?: true, user: user
    end

    test "still unknown", %{user: user} do
      set_mock_probability_processed_food 0.7
      assert_unknown "carrot", using_ai?: true
      assert_unknown "carrot", using_ai?: true, user: user
    end

    test "too many calls", %{user: user} do
      set_mock_probability_processed_food 0.7
      assert_unknown "carrot", using_ai?: true
      assert_unknown "carrot", using_ai?: true, user: user
    end

    def set_mock_probability_processed_food(val) do
      AiNetworkMock.set_mocked_value(val)
    end

  end

  test "closest_match" do
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili"])
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili", "pasta"])
  end

  defp assert_approved(food, opts \\ []) do
    using_ai? = Keyword.get(opts, :using_ai?, false)
    user = Keyword.get(opts, :user)
    if user do
      assert %NelsonApproved.Response{approved?: :approved, using_ai?: ^using_ai?} = NelsonApproved.approved? food, user
    else
      assert %NelsonApproved.Response{approved?: :approved, using_ai?: ^using_ai?} = NelsonApproved.approved? food
    end
  end
  defp assert_not_approved(food, opts \\ []) do
    using_ai? = Keyword.get(opts, :using_ai?, false)
    user = Keyword.get(opts, :user)
    if user do
      assert %NelsonApproved.Response{approved?: :not_approved, using_ai?: ^using_ai?} = NelsonApproved.approved? food, user
    else
      assert %NelsonApproved.Response{approved?: :not_approved, using_ai?: ^using_ai?} = NelsonApproved.approved? food
    end
  end
  defp assert_unknown(food, opts \\ []) do
    using_ai? = Keyword.get(opts, :using_ai?, false)
    user = Keyword.get(opts, :user)
    if user do
      assert %NelsonApproved.Response{approved?: :unknown, using_ai?: ^using_ai?} = NelsonApproved.approved? food, user
    else
      assert %NelsonApproved.Response{approved?: :unknown, using_ai?: ^using_ai?} = NelsonApproved.approved? food
    end
  end


end
