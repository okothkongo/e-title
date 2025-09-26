defmodule ETitleWeb.LandLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Lands
  alias ETitle.Lands.Schemas.Land
  # alias ETitle.Locations

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

        <%= if ETitle.Accounts.account_has_role?(@current_scope.account, "admin") do %>
          <.input
            field={@form[:identity_doc_no]}
            type="text"
            label="Citizen Identity Document Number"
            placeholder="Enter citizen identity doc number"
            required
          />
        <% end %>

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
          phx-change="subcounty_selected"
        />
        <.input
          field={@form[:registry_id]}
          type="select"
          label="Registry"
          options={[{"Select Registry", ""}] ++ @registries}
        />
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
    # Check if user has permission to create land
    if can_create_land?(socket.assigns.current_scope.account) do
      {:ok,
       socket
       |> assign(:return_to, return_to(params["return_to"]))
       |> assign(:sub_counties, [])
       |> assign(:registries, [])
       |> apply_action(socket.assigns.live_action, params)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You don't have permission to create land")
       |> push_navigate(to: ~p"/accounts/log-in")}
    end
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
    # For citizens, set account_id to their own account
    # For admins, account_id will be set when they provide identity_doc_no
    account_id =
      if ETitle.Accounts.account_has_role?(socket.assigns.current_scope.account, "user") do
        socket.assigns.current_scope.account.id
      else
        nil
      end

    land = %Land{account_id: account_id}

    socket
    |> assign(:page_title, "New Land")
    |> assign(:land, land)
    |> assign(:form, to_form(Lands.change_land(socket.assigns.current_scope, land)))
  end

  @impl true
  def handle_event("county_selected", %{"land" => %{"county_id" => county_id}}, socket) do
    sub_counties = list_sub_counties_options(county_id)
    {:noreply, assign(socket, sub_counties: sub_counties)}
  end

  def handle_event("subcounty_selected", %{"land" => %{"sub_county_id" => subcounty_id}}, socket) do
    registries = list_subcount_registries_options(subcounty_id)
    {:noreply, assign(socket, registries: registries)}
  end

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

  defp list_county_options do
    ETitle.Locations.list_counties()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp list_sub_counties_options(county_id) do
    county_id
    |> ETitle.Locations.list_sub_counties_by_county_id()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp list_subcount_registries_options(subcounty_id) do
    subcounty_id
    |> ETitle.Locations.list_registries_by_subcount_id()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp can_create_land?(account) do
    ETitle.Accounts.account_has_role?(account, "user") or
      ETitle.Accounts.account_has_role?(account, "admin")
  end
end
