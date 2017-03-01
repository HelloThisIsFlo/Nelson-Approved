defmodule NelsonApproved.SessionController do
    use NelsonApproved.Web, :controller

    def new(conn, _params) do
      render conn, "new.html"
    end

    def create(conn, _params) do
      render conn, "new.html"
    end

    def delete(conn, _params) do
      render conn, "new.html"
    end
end
