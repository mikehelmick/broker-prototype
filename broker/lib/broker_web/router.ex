defmodule BrokerWeb.Router do
  use BrokerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BrokerWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/events", PageController, :events
    get "/event", PageController, :event
  end

  scope "/deliver", BrokerWeb do
    pipe_through :api

    post "/login_pii_scrubber", EventController, :login_pii_scrubber
    post "/send_email", EventController, :send_email
    post "/login_accounting", EventController, :login_accounting
    post "/experiment_a", EventController, :experiment_a
    post "/experiment_b", EventController, :experiment_b
  end

  scope "/api", BrokerWeb do
    pipe_through :api

    post "/emit", ApiController, :emit
    post "/add_type", ApiController, :add_type
    post "/set_trigger", ApiController, :set_trigger

    get "/list_types", ApiController, :list_types
    get "/list_triggers", ApiController, :list_triggers
  end
  # Other scopes may use custom stacks.
  # scope "/api", BrokerWeb do
  #   pipe_through :api
  # end
end
