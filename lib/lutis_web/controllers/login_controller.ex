defmodule LutisWeb.LoginController do
  use LutisWeb, :controller

  def index(conn, %{"req" => req}) do
    render(conn, "index.html", req: req)
  end

  def index(conn, _) do
    render(conn, "index.html", req: Routes.live_path(conn, LutisWeb.PostIndexLive))
  end

end
