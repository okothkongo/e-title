defmodule ETitleWeb.Router do
  use ETitleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ETitleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ETitleWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/identities", IdentityLive.Index, :index
    live "/identities/new", IdentityLive.Index, :new
    live "/identities/:id/edit", IdentityLive.Index, :edit

    live "/identities/:id", IdentityLive.Show, :show
    live "/identities/:id/show/edit", IdentityLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ETitleWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:e_title, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ETitleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
