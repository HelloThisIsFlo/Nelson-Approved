defmodule NelsonApproved.FoodControllerTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.Food

  test "index shows all available foods", %{conn: conn} do
    insert_food("cheese")
    insert_food("carrot")

    conn = get conn, food_path(conn, :index)

    assert html_response(conn, 200) =~ "Listing Foods"
    assert String.contains? conn.resp_body, "cheese"
    assert String.contains? conn.resp_body, "carrot"
  end

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

  test "render new page", %{conn: conn} do
    conn = get conn, food_path(conn, :new)
    assert html_response(conn, 200) =~ "Create new Food"
    assert conn.resp_body =~ "<form"
  end

  test "create adds food to repo and redirect", %{conn: conn} do
    # Given: No food in Repo
    assert 0 == Enum.count(Repo.all(Food))

    # When: Creating
    conn = post conn, food_path(conn, :index), food: %{name: "Carrot", approved: true}

    # Then: Redirected and food in repo
    assert redirected_to(conn)=~ food_path(conn, :index)
    assert Repo.get_by(Food, %{name: "Carrot"}) != nil
  end

  test "create food with empty name, show error message", %{conn: conn} do
    conn = post conn, food_path(conn, :index), food: %{name: "", approved: true}
    assert html_response(conn, 200)
    assert_response_contains conn, "can't be blank"
  end

  test "create food with duplicate name, show error message", %{conn: conn} do
    # Given: 'Egg' already exists
    insert_food("Egg")

    # When: Trying to save 'Egg'
    conn = post conn, food_path(conn, :index), food: %{name: "Egg", approved: true}

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
