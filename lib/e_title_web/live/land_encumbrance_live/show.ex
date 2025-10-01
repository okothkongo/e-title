defmodule ETitleWeb.LandEncumbranceLive.Show do
  use ETitleWeb, :live_view

  alias ETitle.Lands

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50 py-8">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="mb-8">
            <.header>
              <h1 class="text-3xl font-bold text-gray-900">Land Encumbrance Details</h1>
              <:subtitle>View and manage land encumbrance information</:subtitle>
              <:actions>
                <%= if can_edit_encumbrance?(@current_scope.account, @land_encumbrance) do %>
                  <.button navigate={~p"/land-encumbrances/#{@land_encumbrance}/edit"}>
                    <.icon name="hero-pencil" class="w-5 h-5 mr-2" /> Edit
                  </.button>
                <% end %>
                <%= if can_approve_encumbrance?(@current_scope.account) && @land_encumbrance.status == :pending do %>
                  <.button
                    phx-click="approve"
                    data-confirm="Are you sure you want to approve this encumbrance?"
                    variant="primary"
                  >
                    <.icon name="hero-check" class="w-5 h-5 mr-2" /> Approve
                  </.button>
                <% end %>
                <%= if can_dismiss_encumbrance?(@current_scope.account) && @land_encumbrance.status == :pending do %>
                  <.button
                    phx-click="dismiss"
                    data-confirm="Are you sure you want to dismiss this encumbrance?"
                    variant="danger"
                  >
                    <.icon name="hero-x-mark" class="w-5 h-5 mr-2" /> Dismiss
                  </.button>
                <% end %>
                <%= if can_deactivate_encumbrance?(@current_scope.account) && @land_encumbrance.status == :active do %>
                  <.button
                    phx-click="deactivate"
                    data-confirm="Are you sure you want to deactivate this encumbrance?"
                    variant="danger"
                  >
                    <.icon name="hero-pause" class="w-5 h-5 mr-2" /> Deactivate
                  </.button>
                <% end %>
              </:actions>
            </.header>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <!-- Land Information -->
            <div class="bg-white rounded-lg shadow-md p-6">
              <h2 class="text-xl font-semibold text-gray-900 mb-4">Land Information</h2>
              <div class="space-y-4">
                <div>
                  <span class="text-sm font-medium text-gray-500">Title Number:</span>
                  <p class="text-lg text-gray-900 font-mono">{@land_encumbrance.land.title_number}</p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Size:</span>
                  <p class="text-lg text-gray-900">{@land_encumbrance.land.size} acres</p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">GPS Coordinates:</span>
                  <p class="text-lg text-gray-900 font-mono">
                    {@land_encumbrance.land.gps_cordinates}
                  </p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Registry:</span>
                  <p class="text-lg text-gray-900">{@land_encumbrance.land.registry.name}</p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Land Owner:</span>
                  <p class="text-lg text-gray-900">
                    {@land_encumbrance.land.account.user.first_name} {@land_encumbrance.land.account.user.surname}
                  </p>
                </div>
              </div>
            </div>
            
    <!-- Encumbrance Information -->
            <div class="bg-white rounded-lg shadow-md p-6">
              <h2 class="text-xl font-semibold text-gray-900 mb-4">Encumbrance Information</h2>
              <div class="space-y-4">
                <div>
                  <span class="text-sm font-medium text-gray-500">Reason:</span>
                  <span class={[
                    "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ml-2",
                    @land_encumbrance.reason == :loan && "bg-blue-100 text-blue-800",
                    @land_encumbrance.reason == :bond && "bg-purple-100 text-purple-800"
                  ]}>
                    {String.capitalize(to_string(@land_encumbrance.reason))}
                  </span>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Status:</span>
                  <span class={[
                    "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ml-2",
                    @land_encumbrance.status == :pending && "bg-yellow-100 text-yellow-800",
                    @land_encumbrance.status == :active && "bg-green-100 text-green-800",
                    @land_encumbrance.status == :inactive && "bg-gray-100 text-gray-800",
                    @land_encumbrance.status == :dismissed && "bg-red-100 text-red-800"
                  ]}>
                    {String.capitalize(to_string(@land_encumbrance.status))}
                  </span>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Created For:</span>
                  <p class="text-lg text-gray-900">
                    {@land_encumbrance.created_for.user.first_name} {@land_encumbrance.created_for.user.surname}
                  </p>
                  <p class="text-sm text-gray-600">
                    ID: {@land_encumbrance.created_for.user.identity_doc_no}
                  </p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Created By:</span>
                  <p class="text-lg text-gray-900">
                    {@land_encumbrance.created_by.user.first_name} {@land_encumbrance.created_by.user.surname}
                  </p>
                  <p class="text-sm text-gray-600">
                    Email: {@land_encumbrance.created_by.email}
                  </p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Created At:</span>
                  <p class="text-lg text-gray-900">
                    {Calendar.strftime(@land_encumbrance.inserted_at, "%B %d, %Y at %I:%M %p")}
                  </p>
                </div>
              </div>
            </div>
          </div>
          
    <!-- Approval History -->
          <div class="mt-8 bg-white rounded-lg shadow-md p-6">
            <h2 class="text-xl font-semibold text-gray-900 mb-4">Approval History</h2>
            <div class="space-y-4">
              <%= if @land_encumbrance.approved_by do %>
                <div class="flex items-center space-x-3 p-3 bg-green-50 rounded-lg">
                  <div class="flex-shrink-0">
                    <.icon name="hero-check-circle" class="h-6 w-6 text-green-600" />
                  </div>
                  <div>
                    <p class="text-sm font-medium text-green-800">Approved</p>
                    <p class="text-sm text-green-600">
                      by {@land_encumbrance.approved_by.user.first_name} {@land_encumbrance.approved_by.user.surname}
                    </p>
                    <p class="text-xs text-green-500">
                      {Calendar.strftime(@land_encumbrance.approved_at, "%B %d, %Y at %I:%M %p")}
                    </p>
                  </div>
                </div>
              <% end %>

              <%= if @land_encumbrance.dismissed_by do %>
                <div class="flex items-center space-x-3 p-3 bg-red-50 rounded-lg">
                  <div class="flex-shrink-0">
                    <.icon name="hero-x-circle" class="h-6 w-6 text-red-600" />
                  </div>
                  <div>
                    <p class="text-sm font-medium text-red-800">Dismissed</p>
                    <p class="text-sm text-red-600">
                      by {@land_encumbrance.dismissed_by.user.first_name} {@land_encumbrance.dismissed_by.user.surname}
                    </p>
                    <p class="text-xs text-red-500">
                      {Calendar.strftime(@land_encumbrance.dismissed_at, "%B %d, %Y at %I:%M %p")}
                    </p>
                  </div>
                </div>
              <% end %>

              <%= if @land_encumbrance.deactivated_by do %>
                <div class="flex items-center space-x-3 p-3 bg-orange-50 rounded-lg">
                  <div class="flex-shrink-0">
                    <.icon name="hero-pause-circle" class="h-6 w-6 text-orange-600" />
                  </div>
                  <div>
                    <p class="text-sm font-medium text-orange-800">Deactivated</p>
                    <p class="text-sm text-orange-600">
                      by {@land_encumbrance.deactivated_by.user.first_name} {@land_encumbrance.deactivated_by.user.surname}
                    </p>
                    <p class="text-xs text-orange-500">
                      {Calendar.strftime(@land_encumbrance.deactivated_at, "%B %d, %Y at %I:%M %p")}
                    </p>
                  </div>
                </div>
              <% end %>

              <%= if @land_encumbrance.status == :pending do %>
                <div class="flex items-center space-x-3 p-3 bg-yellow-50 rounded-lg">
                  <div class="flex-shrink-0">
                    <.icon name="hero-clock" class="h-6 w-6 text-yellow-600" />
                  </div>
                  <div>
                    <p class="text-sm font-medium text-yellow-800">Pending Approval</p>
                    <p class="text-sm text-yellow-600">
                      Waiting for land registrar approval
                    </p>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Actions -->
          <div class="mt-8 flex justify-between">
            <.button
              phx-click={JS.navigate(~p"/land-encumbrances")}
              variant="secondary"
            >
              <.icon name="hero-arrow-left" class="w-5 h-5 mr-2" /> Back to Encumbrances
            </.button>

            <%= if can_delete_encumbrance?(@current_scope.account, @land_encumbrance) do %>
              <.button
                phx-click="delete"
                data-confirm="Are you sure you want to delete this encumbrance? This action cannot be undone."
                variant="danger"
              >
                <.icon name="hero-trash" class="w-5 h-5 mr-2" /> Delete Encumbrance
              </.button>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    land_encumbrance = Lands.get_land_encumbrance!(socket.assigns.current_scope, id)

    {:noreply,
     socket
     |> assign(:page_title, "Land Encumbrance Details")
     |> assign(:land_encumbrance, land_encumbrance)}
  end

  @impl true
  def handle_event("approve", _params, socket) do
    case Lands.approve_land_encumbrance(
           socket.assigns.current_scope,
           socket.assigns.land_encumbrance,
           %{status: :active}
         ) do
      {:ok, land_encumbrance} ->
        {:noreply,
         socket
         |> assign(:land_encumbrance, land_encumbrance)
         |> put_flash(:info, "Encumbrance approved successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to approve encumbrance")}
    end
  end

  @impl true
  def handle_event("dismiss", _params, socket) do
    case Lands.dismiss_land_encumbrance(
           socket.assigns.current_scope,
           socket.assigns.land_encumbrance,
           %{status: :dismissed}
         ) do
      {:ok, land_encumbrance} ->
        {:noreply,
         socket
         |> assign(:land_encumbrance, land_encumbrance)
         |> put_flash(:info, "Encumbrance dismissed successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to dismiss encumbrance")}
    end
  end

  @impl true
  def handle_event("deactivate", _params, socket) do
    case Lands.deactivate_land_encumbrance(
           socket.assigns.current_scope,
           socket.assigns.land_encumbrance,
           %{status: :inactive}
         ) do
      {:ok, land_encumbrance} ->
        {:noreply,
         socket
         |> assign(:land_encumbrance, land_encumbrance)
         |> put_flash(:info, "Encumbrance deactivated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to deactivate encumbrance")}
    end
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} =
      Lands.delete_land_encumbrance(socket.assigns.current_scope, socket.assigns.land_encumbrance)

    {:noreply,
     socket
     |> put_flash(:info, "Encumbrance deleted successfully")
     |> push_navigate(to: ~p"/land-encumbrances")}
  end

  defp can_edit_encumbrance?(account, encumbrance) do
    ETitle.Accounts.account_has_role?(account, "admin") or
      encumbrance.created_by_id == account.id
  end

  defp can_approve_encumbrance?(account) do
    ETitle.Accounts.account_has_role?(account, "land_registrar")
  end

  defp can_dismiss_encumbrance?(account) do
    ETitle.Accounts.account_has_role?(account, "land_registrar")
  end

  defp can_deactivate_encumbrance?(account) do
    ETitle.Accounts.account_has_role?(account, "land_registrar")
  end

  defp can_delete_encumbrance?(account, encumbrance) do
    ETitle.Accounts.account_has_role?(account, "admin") or
      encumbrance.created_by_id == account.id
  end
end
