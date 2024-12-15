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
    end

    live_session :require_admin,
      on_mount: [{EcampusWeb.UserAuth, :ensure_authenticated}] do
      live "/admin/specialities", SpecialityLive.Index, :index
      live "/admin/specialities/new", SpecialityLive.Index, :new
      live "/admin/specialities/:id/edit", SpecialityLive.Index, :edit
      live "/admin/specialities/:id", SpecialityLive.Show, :show
      live "/admin/specialities/:id/show/edit", SpecialityLive.Show, :edit

      live "/admin/groups", GroupLive.Index, :index
      live "/admin/groups/new", GroupLive.Index, :new
      live "/admin/groups/:id/edit", GroupLive.Index, :edit
      live "/admin/groups/:id", GroupLive.Show, :show
      live "/admin/groups/:id/show/edit", GroupLive.Show, :edit

      live "/admin/subjects", SubjectLive.Index, :index
      live "/admin/subjects/new", SubjectLive.Index, :new
      live "/admin/subjects/:id/edit", SubjectLive.Index, :edit
      live "/admin/subjects/:id", SubjectLive.Show, :show
      live "/admin/subjects/:id/show/edit", SubjectLive.Show, :edit

      live "/admin/lessons", LessonLive.Index, :index
      live "/admin/lessons/new", LessonLive.Index, :new
      live "/admin/lessons/:id/edit", LessonLive.Index, :edit
      live "/admin/lessons/:id", LessonLive.Show, :show
      live "/admin/lessons/:id/show/edit", LessonLive.Show, :edit

      live "/admin/lessons/:lesson_id/topics", LessonTopicLive.Index, :index
      live "/admin/lessons/:lesson_id/topics/new", LessonTopicLive.Index, :new
      live "/admin/lessons/:lesson_id/topics/:id/edit", LessonTopicLive.Index, :edit
      live "/admin/lessons/:lesson_id/topics/:id", LessonTopicLive.Show, :show
      live "/admin/lessons/:lesson_id/topics/:id/show/edit", LessonTopicLive.Show, :edit
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
