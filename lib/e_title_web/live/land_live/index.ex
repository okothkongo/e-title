defmodule ETitleWeb.LandLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Lands

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Lands
        <:actions>
          <%= if can_create_land?(@current_scope.account) do %>
            <.button variant="primary" navigate={~p"/lands/new"}>
              <.icon name="hero-plus" /> New Land
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.table
        id="lands"
        rows={@streams.lands}
        row_click={fn {_id, land} -> JS.navigate(~p"/lands/#{land}") end}
      >
        <:col :let={{_id, land}} label="Title number">{land.title_number}</:col>
        <:col :let={{_id, land}} label="Size">{land.size}</:col>
        <:col :let={{_id, land}} label="Gps cordinates">{land.gps_cordinates}</:col>
        <:action :let={{_id, land}}>
          <div class="sr-only">
            <.link navigate={~p"/lands/#{land}"}>Show</.link>
          </div>
          <.link navigate={~p"/lands/#{land}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, land}}>
          <.link
            phx-click={JS.push("delete", value: %{id: land.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Lands.subscribe_lands(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Lands")
     |> stream(:lands, list_lands(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    land = Lands.get_land!(socket.assigns.current_scope, id)
    {:ok, _} = Lands.delete_land(socket.assigns.current_scope, land)

    {:noreply, stream_delete(socket, :lands, land)}
  end

  @impl true
  def handle_info({type, %ETitle.Lands.Schemas.Land{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :lands, list_lands(socket.assigns.current_scope), reset: true)}
  end

  defp list_lands(current_scope) do
    Lands.list_lands(current_scope)
  end

  defp can_create_land?(account) do
    ETitle.Accounts.account_has_role?(account, "user") or
      ETitle.Accounts.account_has_role?(account, "admin")
  end
end
