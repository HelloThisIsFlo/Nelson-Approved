defmodule NelsonApproved.PageController do
  use NelsonApproved.Web, :controller

  @nelson_approved Application.fetch_env!(:nelson_approved, :nelson_approved)

  plug :put_default_values
  def put_default_values(conn, _params) do
    conn
    |> assign(:result, :no_result)
    |> assign(:suggestion, "")
    |> assign(:using_ai?, false)
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def why(conn, _params) do
    render conn, "why.html", show_why?: false
  end

  def check(conn, %{"check" => %{"food" => food}}) do
    case @nelson_approved.approved?(food, conn.assigns.current_user) do
      %NelsonApproved.Response{approved?: :unknown, using_ai?: ai?} ->
        render conn, "index.html",
          result: :unknown,
          suggestion: get_suggestion(food),
          using_ai?: ai?
      %NelsonApproved.Response{approved?: result, using_ai?: ai?} ->
        render conn, "index.html", result: result, using_ai?: ai?
    end
  end

  defp get_suggestion(food) do
    suggestion = @nelson_approved.find_closest_match(food, NelsonApproved.FoodNames.all_food_names())
    food = food |> String.downcase() |> String.trim()
    if suggestion != food do
      suggestion
    else
      ""
    end
  end
end
