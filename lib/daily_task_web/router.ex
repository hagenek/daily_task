defmodule DailyTaskWeb.Router do
  use DailyTaskWeb, :router

  import DailyTaskWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DailyTaskWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DailyTaskWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/tasks", TaskLive.Index, :index
    live "/tasks/new", TaskLive.Index, :new
    live "/tasks/:id/edit", TaskLive.Index, :edit
    live "/tasks/:id/split", TaskLive.Index, :split

    live "/tasks/tomorrow", TaskLive.Tomorrow, :index
    live "/tasks/tomorrow/new", TaskLive.Tomorrow, :new
    live "/tasks/tomorrow/:id/edit", TaskLive.Tomorrow, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", DailyTaskWeb do
  #   pipe_through :api
  # end

  # ## Authentication routes
  #
  # scope "/users", DailyTaskWeb do
  #   pipe_through [:browser, :redirect_if_user_is_authenticated]
  #
  #   get "/register", UserRegistrationController, :new
  #   post "/register", UserRegistrationController, :create
  #   get "/log_in", UserSessionController, :new
  #   post "/log_in", UserSessionController, :create
  #   get "/reset_password", UserResetPasswordController, :new
  #   post "/reset_password", UserResetPasswordController, :create
  # end
  #
  # scope "/users", DailyTaskWeb do
  #   pipe_through [:browser, :require_authenticated_user]
  #
  #   get "/settings", UserSettingsController, :edit
  #   put "/settings", UserSettingsController, :update
  #   get "/settings/confirm_email/:token", UserSettingsController, :confirm_email
  # end
  #
  # scope "/users", DailyTaskWeb do
  #   pipe_through [:browser]
  #
  #   delete "/log_out", UserSessionController, :delete
  #   get "/confirm/:token", UserConfirmationController, :edit
  #   post "/confirm/:token", UserConfirmationController, :update
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:daily_task, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DailyTaskWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
