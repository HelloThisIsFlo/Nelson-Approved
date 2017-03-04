defmodule NelsonApproved.FoodTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.Food

  # From test config:
  # Valid food names: banana, pepper, pizza

  describe "basic changeset" do
    test "valid" do
      valid = Food.changeset(%Food{}, %{name: "banana", approved: false})
      assert valid.valid?, inspect(valid)
    end

    test "invalid" do
      invalid1 = Food.changeset(%Food{}, %{name: "", approved: false})
      invalid2 = Food.changeset(%Food{}, %{name: nil, approved: false})
      invalid3 = Food.changeset(%Food{}, %{approved: false})

      refute invalid1.valid?, inspect(invalid1)
      refute invalid2.valid?, inspect(invalid2)
      refute invalid3.valid?, inspect(invalid3)
    end
  end

  test "default value for 'approved'" do
    # Given: No values for 'approved'
    default = Food.changeset(%Food{}, %{name: "banana"})
    not_approved = Food.changeset(%Food{}, %{name: "pizza", approved: false})

    # When: saving and retrieving from DB
    Repo.insert!(default)
    Repo.insert!(not_approved)
    from_repo_default = Repo.get_by(Food, %{name: "banana"})
    from_repo_not_approved = Repo.get_by(Food, %{name: "pizza"})

    # Then: 'Approved' is set to true
    assert from_repo_default.approved
    refute from_repo_not_approved.approved
  end


  describe "sanitize food name" do
    test "food is inserted in lowercase" do
      changeset = Food.changeset(%Food{}, %{name: "Banana"})

      refute changeset.changes.name == "Banana"
      assert changeset.changes.name == "banana"
    end

    test "blank spaces are removed" do
      changeset = Food.changeset(%Food{}, %{name: "   banana  "})
      assert changeset.changes.name == "banana"
    end

    test "can not insert food with duplicate name, ignore case and spaces" do
      # Given: A food already exist with same name
      insert_food("banana", false)

      # Then: Error happens on insert
      changeset = Food.changeset(%Food{}, %{name: "  baNanA", approved: true})
      assert {:error, changeset} = Repo.insert(changeset)
      assert {:name, {"has already been taken", []}} in changeset.errors

      # And: Repo only contains 1 element with name
      from_repo = Repo.all(Food)
      assert Enum.count(from_repo) == 1
    end
  end

  test "can only insert food if food name valid" do
    # A valid food name is a food name contained in the valid food name list
    # For tests the valid food-names are "banana", "pizza" and "carrot"
    # See configuration.
    assert_changeset_valid "pizza"
    assert_changeset_valid "  PiZZa  "

    assert {:name, "is not a food name"} in errors_on(%Food{}, %{name: "abc"})
  end

  defp assert_changeset_valid(name) do
    changeset = Food.changeset(%Food{}, %{name: name})
    assert changeset.valid?
  end

end
