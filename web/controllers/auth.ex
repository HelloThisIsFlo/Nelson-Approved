defmodule NelsonApproved.Auth do
  alias NelsonApproved.Router.Helpers
  import Phoenix.Controller
  import Plug.Conn

  @pass_hash Application.fetch_env!(:nelson_approved, :pass_hash)

  def authenticate(conn, _params) do
    do_authenticate(conn, get_session(conn, :logged_in?))
  end
  defp do_authenticate(conn, logged_in?)
  defp do_authenticate(conn, true), do: conn
  defp do_authenticate(conn, _) do
    conn
    |> halt()
    |> put_flash(:error, "You must be logged-in to access this page")
    |> redirect(to: Helpers.page_path(conn, :index))
  end

  def login(conn) do
    conn
    |> put_session(:logged_in?, true)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end

  def login_with_password(conn, password) do
    if Comeonin.Bcrypt.checkpw(password, @pass_hash) do
      {:ok, login(conn)}
    else
      {:error, conn}
    end
  end


end
