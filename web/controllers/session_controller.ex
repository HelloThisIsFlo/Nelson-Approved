defmodule NelsonApproved.SessionController do
    use NelsonApproved.Web, :controller
    alias NelsonApproved.Auth

    def new(conn, _params) do
      render conn, "new.html"
    end

    def create(conn, %{"password" => pass}) do
      conn
      |> Auth.login_with_password(pass)
      |> do_login
    end

    defp do_login({:ok, conn}) do
      conn
      |> put_flash(:info, "Logged in!")
      |> redirect(to: page_path(conn, :index))
    end
    defp do_login({:error, conn}) do
      conn
      |> put_flash(:error, "Wrong password!")
      |> render("new.html")
    end

    def delete(conn, _params) do
      render conn, "new.html"
    end
end
