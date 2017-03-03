defmodule NelsonApproved.PageController do
  use NelsonApproved.Web, :controller

  @nelson_approved Application.fetch_env!(:nelson_approved, :nelson_approved)

  plug :put_default_values
  def put_default_values(conn, _params) do
    conn
    |> assign(:result, :no_result)
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def why(conn, _params) do
    render conn, "why.html", show_why?: false
  end

  def check(conn, %{"check" => %{"food" => food}}) do
    result = @nelson_approved.approved?(food)
    render conn, "index.html", result: result
  end
end
