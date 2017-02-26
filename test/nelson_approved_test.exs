defmodule NelsonApprovedTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.Repo
  alias NelsonApproved.Food

  setup(context) do
    approved = Map.get(context, :approved, [])
    not_approved = Map.get(context, :not_approved, [])

    Enum.each(approved, &Repo.insert!(%Food{name: &1, approved: true}))
    Enum.each(not_approved, &Repo.insert!(%Food{name: &1, approved: false}))
  end

  test "not in repo => unknown" do
    assert [] == Repo.all(Food)
    assert :unknown == NelsonApproved.approved? "not in repo"
  end

  @tag approved:     ["Carrot"]
  @tag not_approved: ["Pizza"]
  test "in repo => convert value" do
    assert :approved     == NelsonApproved.approved? "Carrot"
    assert :not_approved == NelsonApproved.approved? "Pizza"
  end

  test "closest_match" do
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili"])
    assert "chili" == NelsonApproved.find_closest_match("chil", ["chili", "pasta"])
  end




end
