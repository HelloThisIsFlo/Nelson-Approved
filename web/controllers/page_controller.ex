defmodule NelsonApproved.PageController do
  use NelsonApproved.Web, :controller

  plug :put_default_values
  def put_default_values(conn, _params) do
    conn
    |> assign(:show_why?, true)
    |> assign(:result, :no_result)
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def why(conn, _params) do
    render conn, "why.html", show_why?: false
  end

  def check(conn, %{"check" => %{"food" => food}}) do
    IO.inspect food
    render conn, "index.html", result: :approved
  end
end
