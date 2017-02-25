defmodule NelsonApproved.PageController do
  use NelsonApproved.Web, :controller

  plug :show_why_by_default
  def show_why_by_default(conn, _params), do: assign(conn, :show_why?, true)

  def index(conn, _params) do
    show_why_by_default(conn, [])
    render conn, "index.html"
  end

  def why(conn, _params) do
    render conn, "why.html", show_why?: false
  end

  def check(conn, %{"check" => %{"food" => food}}) do
    IO.inspect food
    render conn, "index.html"
  end
end
