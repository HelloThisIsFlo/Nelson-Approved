defmodule NelsonApproved.UserControllerTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.User
  @valid_attrs %{username: "some content", password: "some content", admin: true}
  @valid_attrs_wo_pass Map.drop(@valid_attrs, [:password])
  @invalid_attrs %{}

  setup(%{conn: conn} = context) do
    conn =
      conn
      |> do_login(context[:logged_in], context[:as_admin])

    %{conn: conn}
  end

  defp do_login(conn, logged_in?, as_admin?)
  defp do_login(conn, true, true), do: login(conn, admin?: true)
  defp do_login(conn, true, _), do: login(conn, admin?: false)
  defp do_login(conn, _, _), do: conn

  test "not logged-in, cannot access user management section", %{conn: conn} do
    Enum.each([
      get(conn, user_path(conn, :index)),
      delete(conn, user_path(conn, :delete, 1))
    ], fn(conn) ->
      flash = get_flash conn, :error
      refute String.length(flash) == 0
      assert redirected_to(conn) =~ session_path(conn, :new)
    end)
  end

  # # TODO: Uncomment when non-admin users feature added
  # @tag :logged_in
  # test "not admin, cannot access user management section", %{conn: conn} do
  #   Enum.each([
  #     get(conn, user_path(conn, :index)),
  #     delete(conn, user_path(conn, :delete, 1))
  #   ], fn(conn) ->
  #     flash = get_flash conn, :error
  #     refute String.length(flash) == 0
  #     assert redirected_to(conn) =~ session_path(conn, :new)
  #   end)
  # end

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

  @tag :logged_in
  @tag :as_admin
  test "deletes chosen resource", %{conn: conn} do
    user = insert_user(username: "A user")
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
