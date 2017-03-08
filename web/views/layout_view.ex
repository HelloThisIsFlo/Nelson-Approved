defmodule NelsonApproved.LayoutView do
  use NelsonApproved.Web, :view
  alias NelsonApproved.User
  import Plug.Conn

  def is_admin(%User{admin: admin?}), do: admin?
  def is_admin(_), do: false

end
