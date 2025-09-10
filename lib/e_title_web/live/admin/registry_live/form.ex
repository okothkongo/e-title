defmodule ETitleWeb.Admin.RegistryLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Locations
  alias ETitle.Locations.Schemas.Registry

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
        <.input
          field={@form[:county_id]}
          type="select"
          label="County"
          options={[{"Select County", ""}] ++ list_county_options()}
          phx-change="county_selected"
        />
        <.input
          field={@form[:sub_county_id]}
          type="select"
          label="Sub County"
          options={[{"Select Sub County", ""}] ++ @sub_counties}
        />
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
     |> assign(:sub_counties, [])
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    registry = %Registry{}

    socket
    |> assign(:page_title, "New Registry")
    |> assign(:registry, registry)
    |> assign(:form, to_form(Locations.change_registry(registry)))
  end

  @impl true
  def handle_event("county_selected", %{"registry" => %{"county_id" => county_id}}, socket) do
    sub_counties = list_sub_counties_options(county_id)
    {:noreply, assign(socket, sub_counties: sub_counties)}
  end

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

  defp save_registry(socket, :new, registry_params) do
    case Locations.create_registry(registry_params) do
      {:ok, _registry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Registry created successfully")
         |> push_navigate(to: ~p"/admin/dashboard")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _registry), do: ~p"/"

  defp list_county_options do
    ETitle.Locations.list_counties()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp list_sub_counties_options(county_id) do
    county_id
    |> ETitle.Locations.list_sub_counties_by_county_id()
    |> Enum.map(&{&1.name, &1.id})
  end
end
