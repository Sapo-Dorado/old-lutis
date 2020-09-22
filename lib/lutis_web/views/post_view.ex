defmodule LutisWeb.PostView do
  use LutisWeb, :view

  def markdown(body) do
    body
    |> sanitize
    |> Earmark.as_html!
    |> fix_ampersands
    |> raw
  end
  
  defp sanitize(body) do
    body
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  defp fix_ampersands(body) do
    String.replace(body, "&amp;", "&")
  end
end
