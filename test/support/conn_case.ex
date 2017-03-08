defmodule NelsonApproved.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias NelsonApproved.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import NelsonApproved.Router.Helpers
      import NelsonApproved.TestHelpers

      # The default endpoint for testing
      @endpoint NelsonApproved.Endpoint


      def login(conn, login?, as_admin?)
      def login(conn, true, true), do: do_login(conn, admin?: true)
      def login(conn, true, _),    do: do_login(conn, admin?: false)
      def login(conn, _, _),       do: conn

      defp do_login(conn, admin?: admin) do
        user = insert_user(admin: admin)

        conn
        |> bypass_through(NelsonApproved.Router, [:browser])
        |> get("/")
        |> NelsonApproved.Auth.login(user)
        |> send_resp(:ok, "Flush the session")
        |> recycle()
      end

    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(NelsonApproved.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(NelsonApproved.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
