defmodule ETitleWeb.RegistryLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Locations
  alias ETitle.Locations.Registry

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage registry records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="registry-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:phone_number]} type="text" label="Phone number" />
        <.input field={@form[:email]} type="text" label="Email" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Registry</.button>
          <.button navigate={return_path(@current_scope, @return_to, @registry)}>Cancel</.button>
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
    registry = Locations.get_registry!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Registry")
    |> assign(:registry, registry)
    |> assign(:form, to_form(Locations.change_registry(socket.assigns.current_scope, registry)))
  end

  defp apply_action(socket, :new, _params) do
    registry = %Registry{}

    socket
    |> assign(:page_title, "New Registry")
    |> assign(:registry, registry)
    |> assign(:form, to_form(Locations.change_registry(registry)))
  end

  @impl true
  def handle_event("validate", %{"registry" => registry_params}, socket) do
    changeset =
      Locations.change_registry(
        socket.assigns.registry,
        registry_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"registry" => registry_params}, socket) do
    save_registry(socket, socket.assigns.live_action, registry_params)
  end

  defp save_registry(socket, :edit, registry_params) do
    case Locations.update_registry(
           socket.assigns.registry,
           registry_params
         ) do
      {:ok, registry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Registry updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, registry)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_registry(socket, :new, registry_params) do
    case Locations.create_registry(registry_params) do
      {:ok, registry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Registry created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, registry)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _registry), do: ~p"/registries"
  defp return_path(_scope, "show", registry), do: ~p"/registries/#{registry}"
end
