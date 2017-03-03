defmodule NelsonApproved.SessionControllerTest do
  use NelsonApproved.ConnCase

  test "renders login page", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert_on_login_page conn
  end

  describe "login" do
    test "correct password", %{conn: conn} do
      # Password for test and dev is "abcd", see `config.exs`
      conn = post conn, session_path(conn, :create), password: "abcd"

      assert get_flash(conn, :info) =~ "Logged in!"
      assert redirected_to(conn) =~ page_path(conn, :index)
      assert get_session(conn, :logged_in?)
    end

    test "wrong password", %{conn: conn} do
      conn = post conn, session_path(conn, :create), password: "xxxx"
      assert get_flash(conn, :error) =~ "Wrong password!"
      assert_on_login_page conn
    end
  end


  defp assert_on_login_page(conn) do
    assert html_response(conn, 200) =~ ~r/[Ll]ogin/
  end

end
