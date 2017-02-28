defmodule NelsonApproved.FoodControllerTest do
  use NelsonApproved.ConnCase
  alias NelsonApproved.Food

  test "index shows all available foods", %{conn: conn} do
    insert_food("cheese")
    insert_food("carrot")

    conn = get conn, "/manage/foods"

    assert html_response(conn, 200) =~ "Listing Foods"
    assert String.contains? conn.resp_body, "cheese"
    assert String.contains? conn.resp_body, "carrot"
  end

  test "delete removes food from repo", %{conn: conn} do
    # Given: Food is in the Repo
    %Food{id: id} = insert_food("fries")
    assert Repo.get(Food, id) != nil

    # When: Deleting
    conn = delete conn, "/manage/foods/" <> to_string(id)

    # Food is deleted & redirected to index
    refute Repo.get(Food, id) != nil
    assert redirected_to(conn)=~ "/manage/foods"
    assert get_flash(conn, :info) =~ "deleted"
  end

end
