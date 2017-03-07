defmodule NelsonApproved.FoodControllerTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.Food

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

  test "not logged-in, cannot access food section", %{conn: conn} do
    Enum.each([
      get(conn, food_path(conn, :index)),
      get(conn, food_path(conn, :new)),
      post(conn, food_path(conn, :create), food: %{}),
      delete(conn, food_path(conn, :delete, 1))
    ], fn(conn) ->
      flash = get_flash conn, :error
      refute String.length(flash) == 0
      assert redirected_to(conn) =~ session_path(conn, :new)
    end)
  end

  @tag :logged_in
  @tag :as_admin
  test "index shows all available foods", %{conn: conn} do
    insert_food("cheese")
    insert_food("carrot")

    conn = get conn, food_path(conn, :index)

    assert html_response(conn, 200) =~ "Listing Foods"
    assert String.contains? conn.resp_body, "cheese"
    assert String.contains? conn.resp_body, "carrot"
  end

  @tag :logged_in
  @tag :as_admin
  test "delete removes food from repo and redirect", %{conn: conn} do
    # Given: Food is in the Repo
    %Food{id: id} = insert_food("fries")
    assert Repo.get(Food, id) != nil

    # When: Deleting
    conn = delete conn, food_path(conn, :delete, %Food{id: id})

    # Food is deleted & redirected to index
    refute Repo.get(Food, id) != nil
    assert redirected_to(conn)=~ food_path(conn, :index)
    assert get_flash(conn, :info) =~ "deleted"
  end

  @tag :logged_in
  @tag :as_admin
  test "render new page", %{conn: conn} do
    conn = get conn, food_path(conn, :new)
    assert html_response(conn, 200) =~ "Create new Food"
    assert conn.resp_body =~ "<form"
  end

  @tag :logged_in
  @tag :as_admin
  test "create adds food to repo and redirect", %{conn: conn} do
    # Given: No food in Repo
    assert 0 == Food |> Repo.all |> Enum.count

    # When: Creating
    conn = post conn, food_path(conn, :index), food: %{name: "carrot", approved: true}

    # Then: Redirected and food in repo
    assert redirected_to(conn)=~ food_path(conn, :index)
    assert Repo.get_by(Food, %{name: "carrot"}) != nil
  end

  @tag :logged_in
  @tag :as_admin
  test "create food with empty name, show error message", %{conn: conn} do
    conn = post conn, food_path(conn, :index), food: %{name: "", approved: true}
    assert html_response(conn, 200)
    assert_response_contains conn, "can't be blank"
  end

  @tag :logged_in
  @tag :as_admin
  test "create food with duplicate name, show error message", %{conn: conn} do
    # Given: 'pizza' already exists
    insert_food("pizza")

    # When: Trying to save 'pizza'
    conn = post conn, food_path(conn, :index), food: %{name: "pizza", approved: true}

    # Error is shown
    assert html_response(conn, 200)
    assert_response_contains conn, "has already been taken"
  end

  defp assert_response_contains(conn, expected) do
    safe_expected =
      expected
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    assert conn.resp_body =~ safe_expected
  end

end
