defmodule LutisWeb.PostView do
  use LutisWeb, :view

  def delete_button(assigns, author) do
    icon = raw("<i data-feather=\"trash-2\"></i>")
    ~L"""
    <span>
      <%=link icon, to: Routes.post_path(@conn, :delete, author, @post.url_id), method: "delete", data: [confirm: "Delete this post?"], class: "delete-button"%>
    </span>
    """
  end
end
