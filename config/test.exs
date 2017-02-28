use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nelson_approved, NelsonApproved.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :nelson_approved, NelsonApproved.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "nelson_approved_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Mock nelson approved service
config :nelson_approved,
  nelson_approved: NelsonApproved.NelsonApprovedMock
