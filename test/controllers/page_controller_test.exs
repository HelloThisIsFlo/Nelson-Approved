defmodule NelsonApproved.PageControllerTest do
  use NelsonApproved.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Nelson Approved"
  end

  test "GET /why", %{conn: conn} do
    conn = get conn, "/why"
    assert html_response(conn, 200)
  end

  test "POST /", %{conn: conn} do
    conn = post conn, "/", %{"check" => %{"food" => ""}}
    html_response(conn, 200)
  end

end
