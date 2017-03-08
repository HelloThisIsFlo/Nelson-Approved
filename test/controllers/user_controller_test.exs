defmodule NelsonApproved.UserControllerTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.User
  @valid_attrs %{username: "some content", password: "some content", admin: false}
  @valid_attrs_admin %{username: "some content", password: "some content", admin: true}
  @invalid_attrs %{}

  setup(%{conn: conn} = context) do
    conn =
      conn
      |> login(context[:logged_in], context[:as_admin])

    %{conn: conn}
  end

  test "not logged-in, cannot access user management section", %{conn: conn} do
    Enum.each([
      get(conn, user_path(conn, :index)),
      delete(conn, user_path(conn, :delete, 1))
    ], fn(conn) ->
      assert get_flash(conn, :error) =~ "must be logged-in"
      assert redirected_to(conn) =~ session_path(conn, :new)
    end)
  end

  @tag :logged_in
  test "not admin, cannot access user management section", %{conn: conn} do
    Enum.each([
      get(conn, user_path(conn, :index)),
      delete(conn, user_path(conn, :delete, 1))
    ], fn(conn) ->
      assert get_flash(conn, :error) =~ "must be an admin"
      assert redirected_to(conn) =~ session_path(conn, :new)
    end)
  end


  @tag :logged_in
  @tag :as_admin
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  # Does not need to be logged in to create a new user
  describe "Create new user => " do
    test "renders form for new resources", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "Register"
    end

    test "create user and log-in", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @valid_attrs

      assert Repo.get_by(User, %{username: @valid_attrs.username})

      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "Welcome !"
      assert conn.assigns.current_user
    end

    test "cannot create admin", %{conn: conn} do
      post conn, user_path(conn, :create), user: @valid_attrs_admin
      created = Repo.get_by(User, %{username: @valid_attrs.username})
      assert created
      refute created.admin
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Register"
    end
  end

  @tag :logged_in
  @tag :as_admin
  test "deletes chosen resource", %{conn: conn} do
    user = insert_user(username: "A user")
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
