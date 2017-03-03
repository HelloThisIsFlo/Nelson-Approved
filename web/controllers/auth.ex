defmodule NelsonApproved.Auth do
  import NelsonApproved.Router.Helpers
  import Phoenix.Controller
  import Plug.Conn

  def login(conn) do
    conn
    |> put_session(:logged_in?, true)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end

  def authenticate(conn, _params) do
    do_authenticate(conn, get_session(conn, :logged_in?))
  end
  defp do_authenticate(conn, logged_in?)
  defp do_authenticate(conn, true), do: conn
  defp do_authenticate(conn, _) do
    conn
    |> halt()
    |> put_flash(:error, "You must be logged-in to access this page")
    |> redirect(to: page_path(conn, :index))
  end




end
