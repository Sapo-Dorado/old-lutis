defmodule LutisWeb.HomePageController do
  use LutisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
