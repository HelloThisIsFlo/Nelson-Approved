defmodule NelsonApproved.UserFoodTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.UserFood
  alias NelsonApproved.Repo

  @invalid_attrs %{}

  setup(context) do
    Map.put(context, :user, insert_user())
  end

  describe "basic changeset" do
    test "valid", %{user: user} do
      valid = user |> build_assoc(:foods) |> UserFood.changeset(%{name: "banana", approved: false})
      assert valid.valid?, inspect(valid)
    end

    test "invalid ", %{user: user} do
      invalid1 = user |> build_assoc(:foods) |> UserFood.changeset(%{name: "", approved: false})
      invalid2 = user |> build_assoc(:foods) |> UserFood.changeset(%{name: nil, approved: false})
      invalid3 = user |> build_assoc(:foods) |> UserFood.changeset(%{approved: false})

      refute invalid1.valid?, inspect(invalid1)
      refute invalid2.valid?, inspect(invalid2)
      refute invalid3.valid?, inspect(invalid3)
    end

    test "user doesn't exist" do
      changeset = UserFood.changeset(%UserFood{user_id: 1}, %{name: "banana", approved: false})
      assert {:error, changeset} = Repo.insert(changeset)
      assert {:user, {"does not exist", []}} in changeset.errors
    end
  end

  test "default value for 'approved'", %{user: user} do
    # Given: No values for 'approved'
    default =      user |> build_assoc(:foods) |> UserFood.changeset(%{name: "banana"})
    not_approved = user |> build_assoc(:foods) |> UserFood.changeset(%{name: "pizza", approved: false})

    # When: saving and retrieving from DB
    Repo.insert!(default)
    Repo.insert!(not_approved)
    from_repo_default = Repo.get_by(UserFood, %{name: "banana"})
    from_repo_not_approved = Repo.get_by(UserFood, %{name: "pizza"})

    # Then: 'Approved' is set to true
    assert from_repo_default.approved
    refute from_repo_not_approved.approved
  end

  describe "sanitize food name" do
    test "food is inserted in lowercase", %{user: user} do
      changeset = user |> build_assoc(:foods) |> UserFood.changeset(%{name: "Banana"})
      refute changeset.changes.name == "Banana"
      assert changeset.changes.name == "banana"
    end

    test "blank spaces removed", %{user: user} do
      changeset = user |> build_assoc(:foods) |> UserFood.changeset(%{name: "       banana      "})
      assert changeset.changes.name == "banana"
    end
  end

  describe "ensure uniqueness" do
    test "same user, cannot insert food with duplicate name", %{user: user} do
      # Given: A food already exist with same name
      insert_user_food(user, "banana", false)

      # Then: Error happens on insert
      changeset = user |> build_assoc(:foods) |> UserFood.changeset(%{name: "banana", approved: true})
      assert {:error, changeset} = Repo.insert(changeset)
      assert {:name, {"has already been taken", []}} in changeset.errors

      # And: Repo only contains 1 element for the current user
      from_repo = Repo.all(UserFood.all_for_user(user))
      assert Enum.count(from_repo) == 1
    end

    test "2 different user, can have food with same name", %{user: user} do
      # Given: Original user has a banana, and another user is available
      insert_user_food(user, "banana", false)
      other_user = insert_user(username: "Other")

      # When: Inserting food for another user, with same name
      other_user
      |> build_assoc(:foods)
      |> UserFood.changeset(%{name: "banana", approved: true})
      |> Repo.insert()

      # And: Repo only contains 1 element for the current user
      user_foods       = Repo.all(UserFood.all_for_user(user))
      other_user_foods = Repo.all(UserFood.all_for_user(other_user))
      all_user_foods   = Repo.all(UserFood)
      assert Enum.count(user_foods) == 1
      assert Enum.count(other_user_foods) == 1
      assert Enum.count(all_user_foods) == 2
      refute user_foods == other_user_foods
    end
  end

end
