defmodule LutisWeb.Router do
  use LutisWeb, :router

  alias LutisWeb.Router.Helpers, as: Routes
  alias Lutis.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LutisWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :check_admin do
    plug :authenticate_user
  end

  pipeline :check_user do
    plug :authenticate_user
  end

  pipeline :check_not_logged_in do
    plug :ensure_no_session
  end


  #When user doesn't have to be logged in
  scope "/", LutisWeb do
    pipe_through :browser
    get "/", HomePageController, :index
    resources "/sessions", SessionController, only: [:create, :delete],
                                              singleton: true
  end

  #When user shouldn't be logged in
  scope "/", LutisWeb do
    pipe_through [:browser, :check_not_logged_in]
    get "/login", LoginController, :index
    resources "/users", UserController, only: [:new, :create]
  end

  #When user login is required
  scope "/", LutisWeb do
    pipe_through [:browser, :check_user]
    get "/profile", UserController, :show 

    get "/settings", UserController, :edit
    patch "/settings", UserController, :update
    put "/settings", UserController, :update

    get "/changepassword", UserController, :edit_pw
    patch "/changepassword", UserController, :update_pw
    put "/changepassword", UserController, :update_pw

    resources "/messages", ThreadController, only: [:new, :create]
    live "/messages", MessagingIndexLive
    live "/messages/:recipient", MessagingLive

    delete "/messages/:recipient", ThreadController, :delete
    post "/messages/:recipient", ThreadController, :send

    resources "/posts", PostController, only: [:new, :create]
    live "/posts", PostIndexLive
    get "/posts/:user/:id", PostController, :show
    get "/posts/:user/:id/edit", PostController, :edit
    patch "/posts/:user/:id", PostController, :update
    put "/posts/:user/:id", PostController, :update
    delete "/posts/:user/:id", PostController, :delete

    post "/posts/:user/:id/upvote", PostController, :upvote
  end

  scope "/admin", LutisWeb, as: :admin do
    pipe_through [:browser, :check_admin]
    resources "/users", UserController, only: [:index, :show, :edit, :update, :delete]
  end


  defp authenticate_user(conn, _) do
    case Accounts.verify_user(conn) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: Routes.login_path(conn, :index, req: conn.request_path))
        |> halt()
      user_id ->
        assign(conn, :current_user, user_id)
    end
  end

  defp ensure_no_session(conn, _) do
    case Accounts.verify_user(conn) do
      nil -> 
        conn
      _user_id ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Already Logged in")
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
    end
  end


  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LutisWeb.Telemetry
    end
  end
end
