defmodule NelsonApproved.Auth do
  import Plug.Conn

  def login(conn) do
    conn
    |> put_session(:logged_in?, true)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end


end
