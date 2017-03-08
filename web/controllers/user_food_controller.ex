defmodule NelsonApproved.UserFoodController do
  use NelsonApproved.Web, :controller

  alias NelsonApproved.UserFood

  def index(conn, _params) do
    user_foods = Repo.all(UserFood)
    render(conn, "index.html", user_foods: user_foods)
  end

  def new(conn, _params) do
    changeset = UserFood.changeset(%UserFood{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_food" => user_food_params}) do
    changeset = UserFood.changeset(%UserFood{}, user_food_params)

    case Repo.insert(changeset) do
      {:ok, _user_food} ->
        conn
        |> put_flash(:info, "User food created successfully.")
        |> redirect(to: user_food_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_food = Repo.get!(UserFood, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_food)

    conn
    |> put_flash(:info, "User food deleted successfully.")
    |> redirect(to: user_food_path(conn, :index))
  end
end
