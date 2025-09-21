defmodule ETitleWeb.LandLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Lands
  alias ETitle.Lands.Land

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage land records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="land-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title_number]} type="text" label="Title number" />
        <.input field={@form[:size]} type="number" label="Size" step="any" />
        <.input field={@form[:gps_cordinates]} type="text" label="Gps cordinates" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Land</.button>
          <.button navigate={return_path(@current_scope, @return_to, @land)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    land = Lands.get_land!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Land")
    |> assign(:land, land)
    |> assign(:form, to_form(Lands.change_land(socket.assigns.current_scope, land)))
  end

  defp apply_action(socket, :new, _params) do
    land = %Land{account_id: socket.assigns.current_scope.account.id}

    socket
    |> assign(:page_title, "New Land")
    |> assign(:land, land)
    |> assign(:form, to_form(Lands.change_land(socket.assigns.current_scope, land)))
  end

  @impl true
  def handle_event("validate", %{"land" => land_params}, socket) do
    changeset = Lands.change_land(socket.assigns.current_scope, socket.assigns.land, land_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"land" => land_params}, socket) do
    save_land(socket, socket.assigns.live_action, land_params)
  end

  defp save_land(socket, :edit, land_params) do
    case Lands.update_land(socket.assigns.current_scope, socket.assigns.land, land_params) do
      {:ok, land} ->
        {:noreply,
         socket
         |> put_flash(:info, "Land updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, land)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_land(socket, :new, land_params) do
    case Lands.create_land(socket.assigns.current_scope, land_params) do
      {:ok, land} ->
        {:noreply,
         socket
         |> put_flash(:info, "Land created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, land)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _land), do: ~p"/lands"
  defp return_path(_scope, "show", land), do: ~p"/lands/#{land}"
end
