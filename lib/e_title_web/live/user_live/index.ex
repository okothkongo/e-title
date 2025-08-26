defmodule ETitleWeb.UserLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Users
        <:actions>
          <.button variant="primary" navigate={~p"/users/new"}>
            <.icon name="hero-plus" /> New User
          </.button>
        </:actions>
      </.header>

      <.table
        id="users"
        rows={@streams.users}
        row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user}") end}
      >
        <:col :let={{_id, user}} label="First name">{user.first_name}</:col>
        <:col :let={{_id, user}} label="Middle name">{user.middle_name}</:col>
        <:col :let={{_id, user}} label="Surname">{user.surname}</:col>
        <:col :let={{_id, user}} label="Identity document">{user.identity_document}</:col>
        <:action :let={{_id, user}}>
          <div class="sr-only">
            <.link navigate={~p"/users/#{user}"}>Show</.link>
          </div>
          <.link navigate={~p"/users/#{user}/edit"}>Edit</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe_users(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
     |> stream(:users, Accounts.list_users(socket.assigns.current_scope))}
  end

  @impl true
  def handle_info({type, %ETitle.Accounts.User{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :users, Accounts.list_users(socket.assigns.current_scope), reset: true)}
  end
end
