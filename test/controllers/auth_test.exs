defmodule NelsonApproved.AuthTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.Auth
  alias NelsonApproved.User

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

  test "login puts user_id in session and user in assign", %{conn: conn} do
    user = %User{username: "Patrick", id: 123}
    conn =
      conn
      |> Auth.login(user)
      |> send_resp(:ok, "")

    # Next request sent by the browser
    new_conn =
      conn
      |> recycle() # Actually will also be recycled in `get` macro
      |> prepare()
      |> send_resp(:ok, "")

    # user_id in session
    assert 123 = get_session(conn, :user_id)
    assert 123 = get_session(new_conn, :user_id)

    # user in assign
    assert ^user = conn.assigns.current_user
  end

  test "logout drops the session, and halts connection", %{conn: conn} do
    conn =
      conn
      |> put_session(:user_id, %User{id: 123})
      |> Auth.logout()
      |> send_resp(:ok, "")

    new_conn =
      conn
      |> recycle()
      |> prepare()

    assert get_session(new_conn, :user_id) == nil
  end

  describe "login_with_username_and_password/2" do
    test "user not found, doesn't log-in", %{conn: conn} do
      {:error, conn} = Auth.login_with_username_and_password(conn, "Frank", "xxxxxxx")
      refute get_session(conn, :user_id)
    end

    test "wrong password, doesn't log-in", %{conn: conn} do
      insert_user(username: "Frank", password: "secret")
      {:error, conn} = Auth.login_with_username_and_password(conn, "Frank", "xxxxxxx")
      refute get_session(conn, :user_id)
    end

    test "correct password, log-in", %{conn: conn} do
      %User{id: id} = insert_user(username: "Frank", password: "secret")
      {:ok, conn} = Auth.login_with_username_and_password(conn, "Frank", "secret")
      assert ^id = get_session(conn, :user_id)
    end
  end

  describe "authenticate_admin/2" do
    test "not logged in, redirect", %{conn: conn} do
      conn =
        conn
        |> Auth.authenticate_admin([])

      assert conn.halted
      assert redirected_to(conn) =~ page_path(conn, :index)
      assert get_flash(conn, :error) =~ "must be logged-in"
    end

    test "logged-in as non-admin, redirect", %{conn: conn} do
      conn =
        conn
        |> Auth.login(%User{id: 1, admin: false})
        |> Auth.authenticate_admin([])

      assert conn.halted
      assert redirected_to(conn) =~ page_path(conn, :index)
      assert get_flash(conn, :error) =~ "must be an admin"
    end

    test "logged-in as admin, do not redirect", %{conn: conn} do
      conn =
        conn
        |> Auth.login(%User{id: 1, admin: true})
        |> Auth.authenticate_admin([])

      refute conn.halted()
      refute conn.state == :sent
    end
  end

  describe "authenticate_logged_in/2" do
    test "not logged in, redirect", %{conn: conn} do
      conn =
        conn
        |> Auth.authenticate_logged_in([])

      assert conn.halted
      assert redirected_to(conn) =~ page_path(conn, :index)
      assert get_flash(conn, :error) =~ "must be logged-in"
    end

    test "logged-in as regular user, do not redirect", %{conn: conn} do
      conn =
        conn
        |> Auth.login(%User{id: 1, admin: false})
        |> Auth.authenticate_logged_in([])

      refute conn.halted()
      refute conn.state == :sent
    end

    test "logged-in as admin, do not redirect", %{conn: conn} do
      conn =
        conn
        |> Auth.login(%User{id: 1, admin: true})
        |> Auth.authenticate_logged_in([])

      refute conn.halted()
      refute conn.state == :sent
    end
  end

  describe "load_current_user/1" do
    test "user not logged-in", %{conn: conn} do
      conn = Auth.load_current_user(conn, [])
      refute conn.assigns.current_user
    end

    test "user logged-in", %{conn: conn} do
      # Given: User is logged-in
      %User{id: id} = insert_user()
      conn = put_session(conn, :user_id, id)

      # When: Loading current user
      conn = Auth.load_current_user(conn, [])

      # Then: Current user is loaded
      assert ^id = conn.assigns.current_user.id
    end

    test "user doesn't exist", %{conn: conn} do
      # Given: Wrong ID is logged in
      conn = put_session(conn, :user_id, 9999)

      # When: Loading current user
      conn = Auth.load_current_user(conn, [])

      # Then: Current user is nil
      refute conn.assigns.current_user
    end
  end

end
