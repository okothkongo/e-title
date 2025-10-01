defmodule ETitleWeb.LandEncumbranceLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Lands

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50 py-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="mb-8">
            <.header>
              <h1 class="text-3xl font-bold text-gray-900">Land Encumbrances</h1>
              <:subtitle>Manage land encumbrances and their status</:subtitle>
              <:actions>
                <%= if can_create_encumbrance?(@current_scope.account) do %>
                  <.button navigate={~p"/land-encumbrances/new"}>
                    <.icon name="hero-plus" class="w-5 h-5 mr-2" /> New Encumbrance
                  </.button>
                <% end %>
              </:actions>
            </.header>
          </div>

          <div class="bg-white rounded-lg shadow-md overflow-hidden">
            <.table
              id="land-encumbrances"
              rows={@streams.land_encumbrances}
              row_click={
                fn {_id, encumbrance} -> JS.navigate(~p"/land-encumbrances/#{encumbrance}") end
              }
            >
              <:col
                :let={{_id, encumbrance}}
                label="Land Title"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900 font-mono">{encumbrance.land.title_number}</span>
              </:col>

              <:col
                :let={{_id, encumbrance}}
                label="Reason"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <span class={[
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                  encumbrance.reason == :loan && "bg-blue-100 text-blue-800",
                  encumbrance.reason == :bond && "bg-purple-100 text-purple-800"
                ]}>
                  {encumbrance.reason}
                </span>
              </:col>

              <:col
                :let={{_id, encumbrance}}
                label="Status"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <span class={[
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                  encumbrance.status == :pending && "bg-yellow-100 text-yellow-800",
                  encumbrance.status == :active && "bg-green-100 text-green-800",
                  encumbrance.status == :inactive && "bg-gray-100 text-gray-800",
                  encumbrance.status == :dismissed && "bg-red-100 text-red-800"
                ]}>
                  {encumbrance.status}
                </span>
              </:col>

              <:col
                :let={{_id, encumbrance}}
                label="Created For"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">
                  {encumbrance.created_for.user.first_name} {encumbrance.created_for.user.surname}
                </span>
              </:col>

              <:col
                :let={{_id, encumbrance}}
                label="Created By"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">
                  {encumbrance.created_by.user.first_name} {encumbrance.created_by.user.surname}
                </span>
              </:col>

              <:col
                :let={{_id, encumbrance}}
                label="Created At"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">
                  {Calendar.strftime(encumbrance.inserted_at, "%b %d, %Y")}
                </span>
              </:col>

              <:col
                :let={{_id, encumbrance}}
                label="Action Timestamps"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <div class="text-sm text-gray-900 space-y-1">
                  <%= if encumbrance.approved_at do %>
                    <div class="text-green-600">
                      ✓ Approved: {Calendar.strftime(encumbrance.approved_at, "%b %d, %Y %H:%M")}
                    </div>
                  <% end %>
                  <%= if encumbrance.dismissed_at do %>
                    <div class="text-red-600">
                      ✗ Dismissed: {Calendar.strftime(encumbrance.dismissed_at, "%b %d, %Y %H:%M")}
                    </div>
                  <% end %>
                  <%= if encumbrance.deactivated_at do %>
                    <div class="text-orange-600">
                      ⏸ Deactivated: {Calendar.strftime(encumbrance.deactivated_at, "%b %d, %Y %H:%M")}
                    </div>
                  <% end %>
                </div>
              </:col>

              <:action :let={{_id, encumbrance}}>
                <div class="flex space-x-2">
                  <.link
                    navigate={~p"/land-encumbrances/#{encumbrance}"}
                    class="text-indigo-600 hover:text-indigo-900"
                  >
                    View
                  </.link>

                  <%= if can_manage_encumbrance?(@current_scope.account, encumbrance) do %>
                    <.link
                      navigate={~p"/land-encumbrances/#{encumbrance}/edit"}
                      class="text-indigo-600 hover:text-indigo-900"
                    >
                      Edit
                    </.link>
                  <% end %>

                  <%= if can_approve_encumbrance?(@current_scope.account) && encumbrance.status == :pending do %>
                    <.link
                      phx-click={JS.push("approve", value: %{id: encumbrance.id})}
                      data-confirm="Are you sure you want to approve this encumbrance?"
                      class="text-green-600 hover:text-green-900"
                    >
                      Approve
                    </.link>
                  <% end %>

                  <%= if can_dismiss_encumbrance?(@current_scope.account) && encumbrance.status == :pending do %>
                    <.link
                      phx-click={JS.push("dismiss", value: %{id: encumbrance.id})}
                      data-confirm="Are you sure you want to dismiss this encumbrance?"
                      class="text-red-600 hover:text-red-900"
                    >
                      Dismiss
                    </.link>
                  <% end %>

                  <%= if can_deactivate_encumbrance?(@current_scope.account) && encumbrance.status == :active do %>
                    <.link
                      phx-click={JS.push("deactivate", value: %{id: encumbrance.id})}
                      data-confirm="Are you sure you want to deactivate this encumbrance?"
                      class="text-orange-600 hover:text-orange-900"
                    >
                      Deactivate
                    </.link>
                  <% end %>

                  <%= if can_delete_encumbrance?(@current_scope.account, encumbrance) do %>
                    <.link
                      phx-click={JS.push("delete", value: %{id: encumbrance.id})}
                      data-confirm="Are you sure?"
                      class="text-red-600 hover:text-red-900"
                    >
                      Delete
                    </.link>
                  <% end %>
                </div>
              </:action>
            </.table>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Lands.subscribe_land_encumbrances(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Land Encumbrances")
     |> stream(:land_encumbrances, list_land_encumbrances(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    encumbrance = Lands.get_land_encumbrance!(socket.assigns.current_scope, id)

    case Lands.approve_land_encumbrance(socket.assigns.current_scope, encumbrance, %{
           status: :active
         }) do
      {:ok, _encumbrance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Encumbrance approved successfully")
         |> stream(:land_encumbrances, list_land_encumbrances(socket.assigns.current_scope),
           reset: true
         )}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to approve encumbrance")}
    end
  end

  @impl true
  def handle_event("dismiss", %{"id" => id}, socket) do
    encumbrance = Lands.get_land_encumbrance!(socket.assigns.current_scope, id)

    case Lands.dismiss_land_encumbrance(socket.assigns.current_scope, encumbrance, %{
           status: :dismissed
         }) do
      {:ok, _encumbrance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Encumbrance dismissed successfully")
         |> stream(:land_encumbrances, list_land_encumbrances(socket.assigns.current_scope),
           reset: true
         )}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to dismiss encumbrance")}
    end
  end

  @impl true
  def handle_event("deactivate", %{"id" => id}, socket) do
    encumbrance = Lands.get_land_encumbrance!(socket.assigns.current_scope, id)

    case Lands.deactivate_land_encumbrance(socket.assigns.current_scope, encumbrance, %{
           status: :inactive
         }) do
      {:ok, _encumbrance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Encumbrance deactivated successfully")
         |> stream(:land_encumbrances, list_land_encumbrances(socket.assigns.current_scope),
           reset: true
         )}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to deactivate encumbrance")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    encumbrance = Lands.get_land_encumbrance!(socket.assigns.current_scope, id)
    {:ok, _} = Lands.delete_land_encumbrance(socket.assigns.current_scope, encumbrance)

    {:noreply, stream_delete(socket, :land_encumbrances, encumbrance)}
  end

  @impl true
  def handle_info({type, %ETitle.Lands.Schemas.LandEncumbrance{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :land_encumbrances, list_land_encumbrances(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_land_encumbrances(current_scope) do
    Lands.list_land_encumbrances(current_scope)
  end

  defp can_create_encumbrance?(account) do
    ETitle.Accounts.account_has_professional_role?(account) or
      ETitle.Accounts.account_has_role?(account, "admin")
  end

  defp can_manage_encumbrance?(account, encumbrance) do
    ETitle.Accounts.account_has_role?(account, "admin") or
      encumbrance.created_by_id == account.id
  end

  defp can_approve_encumbrance?(account) do
    ETitle.Accounts.account_has_role?(account, "land_registrar") or
      ETitle.Accounts.account_has_role?(account, "admin")
  end

  defp can_dismiss_encumbrance?(account) do
    ETitle.Accounts.account_has_role?(account, "land_registrar") or
      ETitle.Accounts.account_has_role?(account, "admin")
  end

  defp can_deactivate_encumbrance?(account) do
    ETitle.Accounts.account_has_role?(account, "land_registrar") or
      ETitle.Accounts.account_has_role?(account, "admin")
  end

  defp can_delete_encumbrance?(account, encumbrance) do
    ETitle.Accounts.account_has_role?(account, "admin") or
      encumbrance.created_by_id == account.id
  end
end
