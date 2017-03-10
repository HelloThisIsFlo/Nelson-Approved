defmodule NelsonApproved.PageControllerIntegrationTest do
  use NelsonApproved.ConnCase, async: false
  alias NelsonApproved.AiCounterMock
  alias NelsonApproved.AiNetworkMock

  @moduletag :integration
  setup(%{conn: conn} = context) do
    AiCounterMock.start_mock()
    AiNetworkMock.start_mock()

    conn = login(conn, context[:logged_in], false)

    conn_with_user =
      conn
      |> bypass_through(NelsonApproved.Router, :browser)
      |> get("/go_through and load user")

    %{conn: conn, logged_in_user: conn_with_user.assigns.current_user}
  end

  test "food approved", %{conn: conn} do
    insert_food("carrot", true)

    conn = post conn, page_path(conn, :check), check: %{"food" => "Carrot"}

    assert html_response(conn, 200) =~ "approved"
    assert conn.assigns.result == :approved
  end

  test "food not approved", %{conn: conn} do
    insert_food("carrot", false)

    conn = post conn, page_path(conn, :check), check: %{"food" => "Carrot"}

    assert html_response(conn, 200) =~ "Stay off"
    assert conn.assigns.result == :not_approved
  end

  test "food unknown, send suggestion", %{conn: conn} do
    mock_ai_response :error

    conn = post conn, page_path(conn, :check), check: %{"food" => "Carrut"}

    assert html_response(conn, 200) =~ "not sure"
    assert conn.assigns.result == :unknown
    assert conn.assigns.suggestion == "carrot"
  end

  test "food unknown, but valid (ignore case). Don't send suggestion", %{conn: conn} do
    mock_ai_response :error

    conn = post conn, page_path(conn, :check), check: %{"food" => " CarroT   "}

    assert html_response(conn, 200) =~ "not sure"
    assert conn.assigns.result == :unknown
    assert conn.assigns.suggestion == ""
  end

  @tag :logged_in
  test "user food override", %{conn: conn, logged_in_user: user} do
    # Given: User & Nelson have different version
    insert_user_food(user, "pizza", true)
    insert_food("pizza", false)

    # When: Checking if food is approved
    conn = post conn, page_path(conn, :check), check: %{"food" => "pizza"}

    # Then: User value is taken
    assert html_response(conn, 200) =~ "approved"
    assert conn.assigns.result == :approved
  end

  defp mock_ai_response(response) do
    AiNetworkMock.set_mocked_value(response)
  end

end
