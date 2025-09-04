defmodule ETitleWeb.RegistryLive.Show do
  use ETitleWeb, :live_view

  alias ETitle.Locations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Registry {@registry.id}
        <:subtitle>This is a registry record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/registries"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/registries/#{@registry}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit registry
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@registry.name}</:item>
        <:item title="Phone number">{@registry.phone_number}</:item>
        <:item title="Email">{@registry.email}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Locations.subscribe_registries(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Registry")
     |> assign(:registry, Locations.get_registry!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %ETitle.Locations.Registry{id: id} = registry},
        %{assigns: %{registry: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :registry, registry)}
  end

  def handle_info(
        {:deleted, %ETitle.Locations.Registry{id: id}},
        %{assigns: %{registry: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current registry was deleted.")
     |> push_navigate(to: ~p"/registries")}
  end

  def handle_info({type, %ETitle.Locations.Registry{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
