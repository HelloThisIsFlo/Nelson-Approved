defmodule NelsonApproved.SessionControllerTest do
  use NelsonApproved.ConnCase

  setup(%{conn: conn}) do
    conn =
      conn
      |> bypass_through(NelsonApproved.Router, [:browser])
      |> get("/")

    %{conn: conn}
  end

  test "renders login page", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert_on_login_page conn
  end

  describe "login" do
    test "correct password, redirects to food page", %{conn: conn} do
      # Password for test and dev is "abcd", see `config.exs`
      conn = post conn, session_path(conn, :create), password: "abcd"

      assert get_flash(conn, :info) =~ "Logged in!"
      assert get_session(conn, :logged_in?)
      assert redirected_to(conn) =~ food_path(conn, :index)

      assert still_logged_in_after_new_connection(conn)
    end

    test "wrong password", %{conn: conn} do
      conn = post conn, session_path(conn, :create), password: "xxxx"
      assert get_flash(conn, :error) =~ "Wrong password!"
      assert_on_login_page conn
    end
  end

  describe "logout" do
    test "logs out", %{conn: conn} do
      # Given: User is logged in
      conn =
        conn
        |> put_session(:logged_in?, true)
        |> send_resp(:ok, "")

      # When: Log out
      conn = delete(conn, session_path(conn, :delete, :not_used))

      # Then: User is logged out
      assert get_flash(conn, :info) =~ "Logged out!"
      assert redirected_to(conn) =~ page_path(conn, :index)

      refute still_logged_in_after_new_connection(conn)
    end
  end

  defp still_logged_in_after_new_connection(conn) do
    conn =
      conn
      |> recycle()
      |> get("/")

    get_session(conn, :logged_in?) == true
  end


  defp assert_on_login_page(conn) do
    assert html_response(conn, 200) =~ ~r/[Ll]ogin/
  end

end
