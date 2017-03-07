defmodule NelsonApproved.TestHelpers do
  alias NelsonApproved.Repo
  alias NelsonApproved.Food
  alias NelsonApproved.User

  def insert_food(name, approved \\ true) do
    %Food{name: name, approved: approved}
    |> Repo.insert!
  end

  def insert_user(attrs \\ []) do
    defaults = [username: "Username", password: "secret_pass"]
    attrs = Keyword.merge(defaults, attrs) |> Enum.into(%{})

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

end
