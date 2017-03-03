defmodule NelsonApproved.LayoutView do
  use NelsonApproved.Web, :view
  import Plug.Conn

  def logged_in?(conn), do: get_session(conn, :logged_in?) == true

end
