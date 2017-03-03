defmodule NelsonApproved.LayoutView do
  use NelsonApproved.Web, :view

  def display_why_link(display? \\ true), do: display?

  def logged_in?(conn) do
    true
  end

end
