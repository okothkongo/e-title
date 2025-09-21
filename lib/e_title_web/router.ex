defmodule ETitleWeb.Router do
  use ETitleWeb, :router

  import ETitleWeb.AccountAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ETitleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_account
  end

  pipeline :authenticated do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ETitleWeb.Layouts, :auth}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_account
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ETitleWeb do
    pipe_through :browser

    live_session :current_account,
      on_mount: [{ETitleWeb.AccountAuth, :mount_current_scope}] do
      live "/", HomeLive.Page
      live "/accounts/register", AccountLive.Registration, :new
      live "/accounts/log-in", AccountLive.Login, :new
      live "/accounts/log-in/:token", AccountLive.Confirmation, :new
    end

    post "/accounts/log-in", AccountSessionController, :create
    delete "/accounts/log-out", AccountSessionController, :delete
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

  ## Authentication routes

  scope "/", ETitleWeb do
    pipe_through [:authenticated, :require_authenticated_account]

    live_session :require_authenticated_account,
      on_mount: [{ETitleWeb.AccountAuth, :require_authenticated}] do
      live "/accounts/settings", AccountLive.Settings, :edit
      live "/accounts/settings/confirm-email/:token", AccountLive.Settings, :confirm_email
    end

    post "/accounts/update-password", AccountSessionController, :update_password
  end

  ## Admin routes

  scope "/admin", ETitleWeb.Admin, as: :admin do
    pipe_through [:authenticated, :require_authenticated_admin_account]

    live_session :require_authenticated_admin_account,
      on_mount: [
        {ETitleWeb.AccountAuth, :require_authenticated_admin}
      ] do
      live "/dashboard", DashboardLive.Dashboard, :index
      live "/registries/new", RegistryLive.Form, :new
      live "/users", UserLive.Index, :index
      live "/accounts", AccountLive.Index, :index
      live "/registries", RegistryLive.Index, :index
      live "/accounts/new", AccountLive.Form, :new
    end
  end

  # non admin routes
  scope "/user" do
    pipe_through [:authenticated, :require_authenticated_non_admin_account]

    live_session :require_authenticated_non_admin_account,
      on_mount: [
        {ETitleWeb.AccountAuth, :require_authenticated_non_admin}
      ] do
      live "/dashboard", ETitleWeb.User.DashboardLive.Dashboard, :index
    end
  end
end
