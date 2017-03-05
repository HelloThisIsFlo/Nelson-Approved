defmodule NelsonApproved.PageView do
  use NelsonApproved.Web, :view
  alias Plug.Conn

  @approved     "Great, it's approved :D :D"
  @not_approved "Stay off that food O_O"
  @unknown      "Actually not sure about that one :/"

  def show_result(%Conn{assigns: assigns}) do
    do_show_result(assigns.result, assigns.using_ai?)
  end
  defp do_show_result(:approved, using_ai?) do
    make_alert "alert-success", @approved, using_ai?
  end
  defp do_show_result(:not_approved, using_ai?) do
    make_alert "alert-danger", @not_approved, using_ai?
  end
  defp do_show_result(:unknown, _) do
    make_alert "alert-warning", @unknown
  end
  defp do_show_result(_, _), do: ""


  defp make_alert(class, content, using_ai? \\ false) do

    content = if using_ai? do
      content <> " &hellip; using AI"
    else
      content
    end

    class = "result alert " <> class
    content_tag :h1, class: class, role: "alert" do
      raw(content)
    end
  end

end
