defmodule NelsonApproved.DefaultValues do
  import Plug.Conn

  # Do nothing simply pass back the options as given.
  def init(opts), do: opts

  # Here from the second parameter is the keyword that was passed in
  # `opts` in the `init(opts)` call.
  def call(conn, show_why?: show_why?) do
    conn
    |> assign(:show_why?, false)
  end

end
