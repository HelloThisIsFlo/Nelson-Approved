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

end
