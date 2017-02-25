defmodule NelsonApproved.PageController do
  use NelsonApproved.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
