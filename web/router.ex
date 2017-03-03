defmodule NelsonApproved.Router do
  use NelsonApproved.Web, :router
  alias NelsonApproved.DefaultValues
  import NelsonApproved.Auth, only: [authenticate: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DefaultValues, show_why?: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NelsonApproved do
    pipe_through :browser

    get  "/",    PageController, :index
    get  "/why", PageController, :why
    post "/",    PageController, :check

    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/manage", NelsonApproved do
    pipe_through [:browser, :authenticate]

    resources "/foods", FoodController, only: [:index, :new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", NelsonApproved do
  #   pipe_through :api
  # end
end
