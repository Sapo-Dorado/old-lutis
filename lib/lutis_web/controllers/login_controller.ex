defmodule LutisWeb.LoginController do
  use LutisWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
