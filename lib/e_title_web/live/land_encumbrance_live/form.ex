defmodule ETitleWeb.LandEncumbranceLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Lands
  alias ETitle.Lands.Schemas.LandEncumbrance

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50 py-8">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="mb-8">
            <.header>
              <h1 class="text-3xl font-bold text-gray-900">
                {if @action == :new, do: "New Land Encumbrance", else: "Edit Land Encumbrance"}
              </h1>
              <:subtitle>
                {if @action == :new,
                  do: "Create a new land encumbrance",
                  else: "Update land encumbrance details"}
              </:subtitle>
            </.header>
          </div>

          <div class="bg-white rounded-lg shadow-md p-6">
            <.form
              for={@form}
              id="land-encumbrance-form"
              phx-change="validate"
              phx-submit="save"
            >
              <div class="grid grid-cols-1 gap-6">
                <div>
                  <.input
                    field={@form[:land_id]}
                    type="select"
                    label="Land"
                    options={@land_options}
                    required
                    prompt="Select a land"
                  />
                </div>

                <div>
                  <.input
                    field={@form[:reason]}
                    type="select"
                    label="Reason"
                    options={[
                      {"Loan", :loan},
                      {"Bond", :bond}
                    ]}
                    required
                    prompt="Select reason"
                  />
                </div>

                <div>
                  <.input
                    field={@form[:identity_doc_no]}
                    type="text"
                    label="Citizen Identity Document Number"
                    placeholder="Enter citizen's identity document number"
                    required
                  />
                </div>

                <%= if @action == :edit do %>
                  <div>
                    <.input
                      field={@form[:status]}
                      type="select"
                      label="Status"
                      options={[
                        {"Pending", :pending},
                        {"Active", :active},
                        {"Inactive", :inactive},
                        {"Dismissed", :dismissed}
                      ]}
                      disabled={true}
                    />
                  </div>
                <% end %>
              </div>

              <div class="mt-8 flex justify-end space-x-3">
                <.button
                  type="button"
                  phx-click={JS.navigate(~p"/land-encumbrances")}
                  variant="secondary"
                >
                  Cancel
                </.button>
                <.button type="submit" variant="primary">
                  {if @action == :new, do: "Create Encumbrance", else: "Update Encumbrance"}
                </.button>
              </div>
            </.form>
          </div>

          <%= if @action == :edit do %>
            <div class="mt-8 bg-white rounded-lg shadow-md p-6">
              <h3 class="text-lg font-medium text-gray-900 mb-4">Encumbrance Details</h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 class="text-sm font-medium text-gray-500 mb-2">Created For</h4>
                  <p class="text-sm text-gray-900">
                    <%= if @land_encumbrance.created_for do %>
                      {@land_encumbrance.created_for.user.first_name} {@land_encumbrance.created_for.user.surname}
                    <% else %>
                      Not assigned
                    <% end %>
                  </p>
                </div>
                <div>
                  <h4 class="text-sm font-medium text-gray-500 mb-2">Created By</h4>
                  <p class="text-sm text-gray-900">
                    <%= if @land_encumbrance.created_by do %>
                      {@land_encumbrance.created_by.user.first_name} {@land_encumbrance.created_by.user.surname}
                    <% else %>
                      Not assigned
                    <% end %>
                  </p>
                </div>
                <%= if @land_encumbrance.approved_by do %>
                  <div>
                    <h4 class="text-sm font-medium text-gray-500 mb-2">Approved By</h4>
                    <p class="text-sm text-gray-900">
                      {@land_encumbrance.approved_by.user.first_name} {@land_encumbrance.approved_by.user.surname}
                    </p>
                  </div>
                <% end %>
                <%= if @land_encumbrance.dismissed_by do %>
                  <div>
                    <h4 class="text-sm font-medium text-gray-500 mb-2">Dismissed By</h4>
                    <p class="text-sm text-gray-900">
                      {@land_encumbrance.dismissed_by.user.first_name} {@land_encumbrance.dismissed_by.user.surname}
                    </p>
                  </div>
                <% end %>
                <%= if @land_encumbrance.deactivated_by do %>
                  <div>
                    <h4 class="text-sm font-medium text-gray-500 mb-2">Deactivated By</h4>
                    <p class="text-sm text-gray-900">
                      {@land_encumbrance.deactivated_by.user.first_name} {@land_encumbrance.deactivated_by.user.surname}
                    </p>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    land_options = get_land_options(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Land Encumbrance Form")
     |> assign(:land_options, land_options)
     |> assign(:land_encumbrance, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    land_encumbrance = Lands.get_land_encumbrance!(socket.assigns.current_scope, id)

    form =
      land_encumbrance
      |> to_form(as: :land_encumbrance)
      |> Map.put(:data, %{
        land_id: land_encumbrance.land_id,
        reason: land_encumbrance.reason,
        identity_doc_no: land_encumbrance.created_for.user.identity_doc_no,
        status: land_encumbrance.status
      })

    socket
    |> assign(:page_title, "Edit Land Encumbrance")
    |> assign(:land_encumbrance, land_encumbrance)
    |> assign(:form, form)
    |> assign(:action, :edit)
  end

  defp apply_action(socket, :new, _params) do
    form = to_form(%LandEncumbrance{}, as: :land_encumbrance)

    socket
    |> assign(:page_title, "New Land Encumbrance")
    |> assign(:land_encumbrance, nil)
    |> assign(:form, form)
    |> assign(:action, :new)
  end

  @impl true
  def handle_event("validate", %{"land_encumbrance" => land_encumbrance_params}, socket) do
    form =
      %LandEncumbrance{}
      |> to_form(land_encumbrance_params)
      |> Map.put(:errors, [])

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"land_encumbrance" => land_encumbrance_params}, socket) do
    save_land_encumbrance(socket, socket.assigns.action, land_encumbrance_params)
  end

  defp save_land_encumbrance(socket, :edit, land_encumbrance_params) do
    case Lands.update_land_encumbrance(
           socket.assigns.current_scope,
           socket.assigns.land_encumbrance,
           land_encumbrance_params
         ) do
      {:ok, _land_encumbrance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Land encumbrance updated successfully")
         |> push_navigate(to: ~p"/land-encumbrances")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_land_encumbrance(socket, :new, land_encumbrance_params) do
    case Lands.create_land_encumbrance(socket.assigns.current_scope, land_encumbrance_params) do
      {:ok, _land_encumbrance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Land encumbrance created successfully")
         |> push_navigate(to: ~p"/land-encumbrances")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_land_options(current_scope) do
    # Get all lands that the current user can access
    lands = Lands.list_lands(current_scope)

    Enum.map(lands, fn land ->
      {land.title_number, land.id}
    end)
  end
end
