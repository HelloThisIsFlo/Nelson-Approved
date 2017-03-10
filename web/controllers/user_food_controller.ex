defmodule NelsonApproved.UserFoodController do
  use NelsonApproved.Web, :controller

  alias NelsonApproved.UserFood

  def index(conn, _params) do
    user =
      conn.assigns.current_user
      |> Repo.preload(:foods)

    render(conn, "index.html", user_foods: user.foods)
  end

  def new(conn, _params) do
    changeset = UserFood.changeset(%UserFood{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_food" => user_food_params}) do
    changeset =
      conn.assigns.current_user
      |> build_assoc(:foods)
      |> UserFood.changeset(user_food_params)

    case Repo.insert(changeset) do
      {:ok, _user_food} ->
        conn
        |> put_flash(:info, "Food preference successfully saved!")
        |> redirect(to: user_food_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do

    user_food =
      conn.assigns.current_user
      |> assoc(:foods)
      |> Repo.get!(id)


    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_food)

    conn
    |> put_flash(:info, "User food deleted successfully.")
    |> redirect(to: user_food_path(conn, :index))
  end
end
