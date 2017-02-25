defmodule NelsonApproved.LayoutView do
  use NelsonApproved.Web, :view

  def display_why_link(display? \\ true), do: display?
end
