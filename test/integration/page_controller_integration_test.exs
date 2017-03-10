defmodule NelsonApproved.PageControllerIntegrationTest do
  use NelsonApproved.ConnCase, async: false
  alias NelsonApproved.AiCounterMock
  alias NelsonApproved.AiNetworkMock

  @moduletag :integration
  setup do
    AiCounterMock.start_mock()
    AiNetworkMock.start_mock()
    :ok
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

  defp mock_ai_response(response) do
    AiNetworkMock.set_mocked_value(response)
  end

end
