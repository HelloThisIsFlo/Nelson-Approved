defmodule NelsonApproved.SessionControllerTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.User

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
      # Given: A user exist
      insert_user(username: "Frank", password: "secret_password")

      # When: logging with the correct password
      conn = post_login_form conn, "Frank", "secret_password"

      assert get_flash(conn, :info) =~ "Logged in!"
      assert %User{username: "Frank"} = conn.assigns.current_user
      assert redirected_to(conn) =~ food_path(conn, :index)

      assert still_logged_in_after_new_connection(conn)
    end

    test "wrong password", %{conn: conn} do
      # Given: A user exist
      insert_user(username: "Frank", password: "abcde")

      # When: logging with the wrong password
      conn = post_login_form conn, "Frank", "xxxx"

      # Then: still on login page
      assert get_flash(conn, :error) =~ "Wrong username/password combination!"
      assert_on_login_page conn
    end

    defp post_login_form(conn, username, password),
      do: post conn, session_path(conn, :create), login: %{username: username, password: password}
  end

  describe "logout" do
    test "logs out", %{conn: conn} do
      # Given: User is logged in
      conn =
        conn
        |> put_session(:user_id, 1234)
        |> send_resp(:ok, "")

      # When: Log out
      conn = delete(conn, session_path(conn, :delete, :not_used))

      # Then: User is logged out
      assert redirected_to(conn) =~ page_path(conn, :index)
      refute still_logged_in_after_new_connection(conn)
    end
  end

  defp still_logged_in_after_new_connection(conn) do
    conn =
      conn
      |> recycle()
      |> get("/")

    get_session(conn, :user_id) != nil
  end


  defp assert_on_login_page(conn) do
    assert html_response(conn, 200) =~ ~r/[Ll]ogin/
  end

end
