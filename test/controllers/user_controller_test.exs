defmodule NelsonApproved.UserControllerTest do
  use NelsonApproved.ConnCase

  alias NelsonApproved.User
  @valid_attrs %{username: "some content", password: "some content", admin: true}
  @valid_attrs_wo_pass Map.drop(@valid_attrs, [:password])
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  describe "Create new user => " do
    test "renders form for new resources", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New user"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @valid_attrs

      assert Repo.get_by(User, @valid_attrs_wo_pass)

      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "Welcome !"
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New user"
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    user = insert_user()
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
