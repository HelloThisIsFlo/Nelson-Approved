defmodule NelsonApproved.TestHelpers do
  alias NelsonApproved.Repo
  alias NelsonApproved.Food

  def insert_food(name, approved \\ true) do
    %Food{name: name, approved: approved}
    |> Repo.insert!
  end

end
