# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :nelson_approved,
  ecto_repos: [NelsonApproved.Repo],
  nelson_approved: NelsonApproved


config :nelson_approved,
  related_thres: 0.02,
  not_related_thres: 0.01


# Configure authentication
config :nelson_approved,
  food_names_file: "./lib/food.txt",
  network_ai_module: NelsonApproved.ArtificialIntelligence.Network,
  counter_ai_module: NelsonApproved.ArtificialIntelligence.Counter


# Configures the endpoint
config :nelson_approved, NelsonApproved.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gMVt8Jcwl7QcG6cU/OA5uPQj7cDbrfgh+cn/71HcK7LpGEEl85HpUerS15p7hQ2g",
  render_errors: [view: NelsonApproved.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NelsonApproved.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
