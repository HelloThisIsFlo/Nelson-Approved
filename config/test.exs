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

# Config for tests
config :nelson_approved,
  nelson_approved: NelsonApproved.NelsonApprovedMock,
  network_ai_module: NelsonApproved.AiNetworkMock,
  food_names_file: "./test/food.txt"


config :nelson_approved,
  related_thres: 0.8,
  not_related_thres: 0.3


# Reduce hash strength for faster tests (only in tests)
config :comeonin,
  bcrypt_log_rounds: 4,
  pbkdf2_rounds: 1


import_config "secret.exs"
