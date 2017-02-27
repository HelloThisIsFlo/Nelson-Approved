defmodule NelsonApproved.FoodTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.Food

  test "valid changeset" do
    valid = Food.changeset(%Food{}, %{name: "rice", approved: false})
    assert valid.valid?, inspect(valid)
  end

  test "invalid changeset" do
    invalid1 = Food.changeset(%Food{}, %{name: "", approved: false})
    invalid2 = Food.changeset(%Food{}, %{name: nil, approved: false})
    invalid3 = Food.changeset(%Food{}, %{approved: false})

    refute invalid1.valid?, inspect(invalid1)
    refute invalid2.valid?, inspect(invalid2)
    refute invalid3.valid?, inspect(invalid3)
  end

  test "default value for 'approved'" do
    # Given: No values for 'approved'
    default = Food.changeset(%Food{}, %{name: "default"})
    not_approved = Food.changeset(%Food{}, %{name: "not approved", approved: false})

    # When: saving and retrieving from DB
    Repo.insert!(default)
    Repo.insert!(not_approved)
    from_repo_default = Repo.get_by(Food, %{name: "default"})
    from_repo_not_approved = Repo.get_by(Food, %{name: "not approved"})

    # Then: 'Approved' is set to true
    assert from_repo_default.approved
    refute from_repo_not_approved.approved
  end

  test "can not insert food with duplicate name" do
    # Given: A food already exist with same name
    Repo.insert!(%Food{name: "existing", approved: false})

    # Then: Error happens on insert
    changeset = Food.changeset(%Food{}, %{name: "existing", approved: true})
    assert {:error, changeset} = Repo.insert(changeset)
    assert {:name, {"has already been taken", []}} in changeset.errors

    # And: Repo only contains 1 element with name
    from_repo = Repo.all(Food)
    assert Enum.count(from_repo) == 1
  end


end
