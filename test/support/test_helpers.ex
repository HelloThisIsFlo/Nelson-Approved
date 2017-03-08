defmodule NelsonApproved.TestHelpers do
  alias NelsonApproved.Repo
  alias NelsonApproved.Food
  alias NelsonApproved.User
  alias NelsonApproved.UserFood
  import Ecto

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

  def insert_user_food(user, name, approved \\ true) do
    user
    |> build_assoc(:foods)
    |> UserFood.changeset(%{name: name, approved: approved})
    |> Repo.insert!()
  end

end
