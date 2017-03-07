defmodule NelsonApproved.Auth do
  alias NelsonApproved.Router.Helpers
  alias NelsonApproved.User
  alias NelsonApproved.Repo
  import Phoenix.Controller
  import Plug.Conn

  def load_current_user(conn, _params) do
    do_load_current_user(conn, get_session(conn, :user_id))
  end
  def do_load_current_user(conn, nil), do: conn
  def do_load_current_user(conn, user_id) do
    assign(conn, :current_user, Repo.get(User, user_id))
  end


  def authenticate_admin(conn, _params) do
    do_authenticate_admin(conn, conn.assigns[:current_user])
  end

  defp do_authenticate_admin(conn, %User{admin: true}), do: conn
  defp do_authenticate_admin(conn, %User{admin: false}) do
    conn
    |> halt()
    |> put_flash(:error, "You must be an admin to access this page")
    |> redirect(to: Helpers.session_path(conn, :new))
  end
  defp do_authenticate_admin(conn, _) do
    conn
    |> halt()
    |> put_flash(:error, "You must be logged-in to access this page")
    |> redirect(to: Helpers.session_path(conn, :new))
  end


  def login(conn, %User{} = user) do
    conn
    |> put_session(:user_id, user.id)
    |> assign(:current_user, user)
    |> configure_session(renew: true)
  end


  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end


  def login_with_username_and_password(conn, username, password) do
    user = Repo.get_by(User, %{username: username})

    cond do
      user && check_pw(user, password) ->
        {:ok, login(conn, user)}
      true ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, conn}
    end
  end

  defp check_pw(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.pass_hash)
  end


end
