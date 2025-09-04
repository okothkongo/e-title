defmodule ETitleWeb.RegistryLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Locations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Registries
        <:actions>
          <.button variant="primary" navigate={~p"/registries/new"}>
            <.icon name="hero-plus" /> New Registry
          </.button>
        </:actions>
      </.header>

      <.table
        id="registries"
        rows={@streams.registries}
        row_click={fn {_id, registry} -> JS.navigate(~p"/registries/#{registry}") end}
      >
        <:col :let={{_id, registry}} label="Name">{registry.name}</:col>
        <:col :let={{_id, registry}} label="Phone number">{registry.phone_number}</:col>
        <:col :let={{_id, registry}} label="Email">{registry.email}</:col>
        <:action :let={{_id, registry}}>
          <div class="sr-only">
            <.link navigate={~p"/registries/#{registry}"}>Show</.link>
          </div>
          <.link navigate={~p"/registries/#{registry}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, registry}}>
          <.link
            phx-click={JS.push("delete", value: %{id: registry.id}) |> hide("##{id}")}
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
      Locations.subscribe_registries(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Registries")
     |> stream(:registries, list_registries(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    registry = Locations.get_registry!(socket.assigns.current_scope, id)
    {:ok, _} = Locations.delete_registry(socket.assigns.current_scope, registry)

    {:noreply, stream_delete(socket, :registries, registry)}
  end

  @impl true
  def handle_info({type, %ETitle.Locations.Registry{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :registries, list_registries(socket.assigns.current_scope), reset: true)}
  end

  defp list_registries(current_scope) do
    Locations.list_registries(current_scope)
  end
end
