defmodule LutisWeb.LayoutView do
  use LutisWeb, :view

  def navbar(assigns) do
    ~L"""
    <header class="sticky">
      <%= if (Lutis.Accounts.verify_user(@conn) == nil) do %>
        <%= login_bar(assigns)%>
      <% else %>
        <%= logged_in_bar(assigns)%>
      <%end%>
    </header>
    """
  end

  defp login_bar(assigns) do
    ~L"""
    <a class="logo" href="/"><img src="<%=Routes.static_path(@conn, "/images/navbarlogo.png")%>"></a>
    <a class="btn btn-a round btn-sm" href="<%=Routes.live_path(@conn, LutisWeb.PostIndexLive)%>">View Posts</a>
    <a class="btn btn-b round btn-sm" href="<%=Routes.user_path(@conn, :new)%>">Sign Up</a>
    <a class="btn btn-c round btn-sm" href="<%=Routes.login_path(@conn,:index)%>">Log In</a>
    """
  end

  defp logged_in_bar(assigns) do
    ~L"""
    <a class="logo" href="<%=Routes.user_path(@conn, :show)%>"><img src="<%= Routes.static_path(@conn, "/images/navbarlogo.png")%>"></a>
    <a class="btn btn-a round btn-sm" href="<%=Routes.live_path(@conn, LutisWeb.PostIndexLive)%>">View Posts</a>
    <a class="btn btn-b round btn-sm" href="<%=Routes.live_path(@conn,LutisWeb.MessagingIndexLive)%>">View Messages</a>
    <%= form_for @conn, Routes.session_path(@conn, :delete), [method: :delete, as: :user], fn _ -> %>
        <%= submit "Logout", class: "btn btn-c round btn-sm" %>
    <% end %>
    """
  end

  defp live_logged_in_bar(assigns) do
    ~L"""
    <a class="logo" href="<%=Routes.user_path(@socket,:show)%>"><img src="<%= Routes.static_path(@socket, "/images/navbarlogo.png")%>"></a>
    <a class="btn btn-a round btn-sm" href="<%=Routes.live_path(@socket, LutisWeb.PostIndexLive)%>">View Posts</a>
    <a class="btn btn-b round btn-sm" href="<%=Routes.live_path(@socket,LutisWeb.MessagingIndexLive)%>">View Messages</a>
    <%= _ = form_for :logout, Routes.session_path(@socket, :delete), [method: :delete, as: :user]%>
        <%= submit "Logout", class: "btn btn-c round btn-sm" %>
    </form>
    """
  end

  defp live_login_bar(assigns) do
    ~L"""
    <a class="logo" href="/"><img src="<%=Routes.static_path(@socket, "/images/navbarlogo.png")%>"></a>
    <a class="btn btn-a round btn-sm" href="<%=Routes.live_path(@socket, LutisWeb.PostIndexLive)%>">View Posts</a>
    <a class="btn btn-b round btn-sm" href="<%=Routes.user_path(@socket, :new)%>">Sign Up</a>
    <a class="btn btn-c round btn-sm" href="<%=Routes.login_path(@socket,:index)%>">Log In</a>
    """
  end


  defp live_bar(assigns) do
    ~L"""
    <header class="sticky">
      <%= if is_nil(@session["user_id"]) do %>
        <%= live_login_bar(assigns)%>
      <% else %>
        <%= live_logged_in_bar(assigns)%>
      <%end%>
    </header>
    """
  end

end
