defmodule EcampusWeb.Router do
  use EcampusWeb, :router

  import EcampusWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EcampusWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EcampusWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", EcampusWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ecampus, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EcampusWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", EcampusWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{EcampusWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", EcampusWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EcampusWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/specialities", SpecialityLive.Index, :index
      live "/specialities/new", SpecialityLive.Index, :new
      live "/specialities/:id/edit", SpecialityLive.Index, :edit
      live "/specialities/:id", SpecialityLive.Show, :show
      live "/specialities/:id/show/edit", SpecialityLive.Show, :edit

      live "/groups", GroupLive.Index, :index
      live "/groups/new", GroupLive.Index, :new
      live "/groups/:id/edit", GroupLive.Index, :edit
      live "/groups/:id", GroupLive.Show, :show
      live "/groups/:id/show/edit", GroupLive.Show, :edit

      live "/subjects", SubjectLive.Index, :index
      live "/subjects/new", SubjectLive.Index, :new
      live "/subjects/:id/edit", SubjectLive.Index, :edit
      live "/subjects/:id", SubjectLive.Show, :show
      live "/subjects/:id/show/edit", SubjectLive.Show, :edit

      live "/lessons", LessonLive.Index, :index
      live "/lessons/new", LessonLive.Index, :new
      live "/lessons/:id/edit", LessonLive.Index, :edit
      live "/lessons/:id", LessonLive.Show, :show
      live "/lessons/:id/show/edit", LessonLive.Show, :edit
    end
  end

  scope "/", EcampusWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{EcampusWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
