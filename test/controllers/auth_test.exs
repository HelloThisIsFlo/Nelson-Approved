defmodule NelsonApproved.AuthTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.Auth

  setup(%{conn: conn}) do
    %{conn: prepare(conn)}
  end

  # Prepare the connection by passing through the phoenix pipeline
  # but stopping before going into controllers
  defp prepare(conn) do
    conn
    |> bypass_through(NelsonApproved.Router, [:browser])
    |> get("/")
  end

  test "login sets flag in session", %{conn: conn} do
    conn =
      conn
      |> Auth.login()
      |> send_resp(:ok, "")

    # Next request sent by the browser
    new_conn =
      conn
      |> recycle() # Actually will also be recycled in `get` macro
      |> prepare()
      |> send_resp(:ok, "")

    assert get_session(conn, :logged_in?) == true
    assert get_session(new_conn, :logged_in?) == true
  end

  test "logout drops the session", %{conn: conn} do
    conn =
      conn
      |> put_session(:logged_in?, true)
      |> Auth.logout()
      |> send_resp(:ok, "")

    new_conn =
      conn
      |> recycle()
      |> prepare()

    assert get_session(new_conn, :logged_in?) == nil
  end

  describe "login_with_password/2" do
    test "wrong password, doesn't log-in", %{conn: conn} do
      {:error, conn} = Auth.login_with_password(conn, "xxxxxxx")
      refute get_session(conn, :logged_in?)
    end

    test "correct password, log-in", %{conn: conn} do
      # Password for test and dev is "abcd", see `config.exs`
      {:ok, conn} = Auth.login_with_password(conn, "abcd")
      assert get_session(conn, :logged_in?)
    end
  end

  describe "authenticate/2" do
    test "redirects if not logged-in", %{conn: conn} do
      conn =
        conn
        |> Auth.authenticate([])

      assert conn.halted
      assert redirected_to(conn) =~ page_path(conn, :index)
      assert get_flash(conn, :error) =~ "must be logged-in"
    end

    test "does not redirect if user logged-in", %{conn: conn} do
      conn =
        conn
        |> Auth.login()
        |> Auth.authenticate([])

      refute conn.halted()
      refute conn.state == :sent
    end
  end

end
