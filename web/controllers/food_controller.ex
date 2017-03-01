defmodule NelsonApproved.FoodController do
  use NelsonApproved.Web, :controller
  alias NelsonApproved.Food

  def index(conn, _params) do
    render conn, "index.html", foods: Repo.all(Food)
  end

  def new(conn, _params) do
    changeset = Food.changeset(%Food{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"food" => %{"name" => name, "approved" => approved}}) do
    changeset =
      %Food{}
      |> Food.changeset(%{name: name, approved: approved})

    case Repo.insert changeset do
      {:ok, _} ->
        redirect(conn, to: food_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    food =
      Food
      |> Repo.get!(id)
      |> Repo.delete!

    conn
    |> put_flash(:info, "Food \"" <> food.name <> "\" successfully deleted")
    |> redirect(to: food_path(conn, :index))
  end


end
