defmodule NelsonApproved.SessionControllerTest do
  use NelsonApproved.ConnCase

  test "renders login page", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ ~r/[Ll]ogin/
  end


end
