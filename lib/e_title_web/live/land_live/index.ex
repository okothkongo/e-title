defmodule ETitleWeb.LandLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Lands

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <div class="relative flex justify-center items-center mb-6">
            <.header>
              <h1 class="text-2xl font-bold text-green-700">Lands</h1>
              <:actions>
                <%= if can_create_land?(@current_scope.account) do %>
                  <.button navigate={~p"/lands/new"}>
                    <.icon name="hero-plus" /> New Land
                  </.button>
                <% end %>
              </:actions>
            </.header>
          </div>

          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <.table
              id="lands"
              rows={@streams.lands}
              row_click={fn {_id, land} -> JS.navigate(~p"/lands/#{land}") end}
            >
              <:col
                :let={{_id, land}}
                label="Title Number"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{land.title_number}</span>
              </:col>

              <:col
                :let={{_id, land}}
                label="Size"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{land.size}</span>
              </:col>

              <:col
                :let={{_id, land}}
                label="GPS Coordinates"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-600">{land.gps_cordinates}</span>
              </:col>

              <:col
                :let={{_id, land}}
                :if={ETitle.Accounts.account_has_role?(@current_scope.account, "admin")}
                label="Owner"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">
                  {land.account.user.first_name} {land.account.user.surname}
                </span>
              </:col>

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
          </div>
        </div>
      </div>
    </div>
    <Layouts.flash_group flash={@flash} />
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
