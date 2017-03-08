defmodule NelsonApproved.Router do
  use NelsonApproved.Web, :router
  alias NelsonApproved.DefaultValues
  import NelsonApproved.Auth, only: [load_current_user: 2, authenticate_admin: 2, authenticate_logged_in: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DefaultValues, show_why?: true
    plug :load_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NelsonApproved do
    pipe_through :browser

    get  "/",    PageController, :index
    post "/",    PageController, :check
    get  "/why", PageController, :why

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/users", UserController, only: [:new, :create]
  end


  scope "/private/", NelsonApproved do
    pipe_through [:browser, :authenticate_logged_in]

    resources "/user_foods", UserFoodController, only: [:index, :new, :create, :delete]
  end

  scope "/manage", NelsonApproved do
    pipe_through [:browser, :authenticate_admin]

    resources "/foods", FoodController, only: [:index, :new, :create, :delete]
    resources "/users", UserController, only: [:index, :delete]
  end


  # Other scopes may use custom stacks.
  # scope "/api", NelsonApproved do
  #   pipe_through :api
  # end
end
