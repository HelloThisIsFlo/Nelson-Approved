defmodule NelsonApproved.FoodController do
  use NelsonApproved.Web, :controller
  alias NelsonApproved.Food

  plug :put_default_values
  def put_default_values(conn, _params) do
    conn
    |> assign(:show_why?, false)
  end

  def index(conn, _params) do
    render conn, "index.html", foods: Repo.all(Food)
  end

  def new(conn, _paramd) do
    render conn, "new.html"
  end

  def create(conn, _params) do
    redirect(conn, to: food_path(conn, :index))
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
