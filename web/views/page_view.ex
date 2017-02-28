defmodule NelsonApproved.PageView do
  use NelsonApproved.Web, :view

  @approved     "Great, it's approved :D :D"
  @not_approved "Stay off that food O_O"
  @unknown      "Actually not sure about that one :/"

  def show_result(:approved) do
    make_alert "alert-success", @approved
  end
  def show_result(:not_approved) do
    make_alert "alert-danger", @not_approved
  end
  def show_result(:unknown) do
    make_alert "alert-warning", @unknown
  end
  def show_result(_), do: ""


  defp make_alert(class, content) do
    class = "result alert " <> class
    content_tag :h1, class: class, role: "alert" do
      content
    end
  end

end
