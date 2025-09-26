defmodule ETitleWeb.LandLive.Show do
  use ETitleWeb, :live_view

  alias ETitle.Lands

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Land {@land.id}
        <:subtitle>This is a land record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/lands"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/lands/#{@land}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit land
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title number">{@land.title_number}</:item>
        <:item title="Size">{@land.size}</:item>
        <:item title="Gps cordinates">{@land.gps_cordinates}</:item>
        <:item :if={ETitle.Accounts.account_has_role?(@current_scope.account, "admin")} title="Owner">
          {@land.account.user.first_name} {@land.account.user.surname}
        </:item>
        <:item
          :if={ETitle.Accounts.account_has_role?(@current_scope.account, "admin")}
          title="Owner Email"
        >
          {@land.account.email}
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Lands.subscribe_lands(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Land")
     |> assign(:land, Lands.get_land!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %ETitle.Lands.Schemas.Land{id: id} = land},
        %{assigns: %{land: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :land, land)}
  end

  def handle_info(
        {:deleted, %ETitle.Lands.Schemas.Land{id: id}},
        %{assigns: %{land: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current land was deleted.")
     |> push_navigate(to: ~p"/lands")}
  end

  def handle_info({type, %ETitle.Lands.Schemas.Land{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
