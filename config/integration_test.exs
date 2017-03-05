use Mix.Config

import_config "test.exs"

# Override test config
config :nelson_approved,
  nelson_approved: NelsonApproved


config :nelson_approved,
  related_thres: 0.8,
  not_related_thres: 0.3


