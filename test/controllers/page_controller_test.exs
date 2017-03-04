defmodule NelsonApproved.PageControllerTest do
  use NelsonApproved.ConnCase, async: false

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Nelson Approved"
  end

  test "GET /why", %{conn: conn} do
    conn = get conn, "/why"
    assert html_response(conn, 200)
  end

  test "food approved", %{conn: conn} do
    set_mock_response :approved

    conn = post conn, page_path(conn, :check), check: %{"food" => "Carrot"}

    assert html_response(conn, 200) =~ "approved"
    assert conn.assigns.result == :approved
  end

  test "food not approved", %{conn: conn} do
    set_mock_response :not_approved

    conn = post conn, page_path(conn, :check), check: %{"food" => "Carrot"}

    assert html_response(conn, 200) =~ "Stay off"
    assert conn.assigns.result == :not_approved
  end

  test "food unknown, send suggestion", %{conn: conn} do
    set_mock_response :unknown
    set_mock_response "Carrot"

    conn = post conn, page_path(conn, :check), check: %{"food" => "Carrut"}

    assert html_response(conn, 200) =~ "not sure"
    assert conn.assigns.result == :unknown
    assert conn.assigns.suggestion == "Carrot"
  end

  test "food unknown, but valid (ignore case). Don't send suggestion", %{conn: conn} do
    set_mock_response :unknown
    set_mock_response "carrot"

    conn = post conn, page_path(conn, :check), check: %{"food" => " CarroT   "}

    assert html_response(conn, 200) =~ "not sure"
    assert conn.assigns.result == :unknown
    assert conn.assigns.suggestion == ""
  end

  # When called, the mock NelsonApproved service sinply sends back the first
  # message found in the inbox.
  # So before test, sending response to self() for the mock to find it.
  # For a more bulletproof approach, use a genserver on the Mock instead of same
  # process as the test.
  defp set_mock_response(response) do
    send self(), response
  end

end
