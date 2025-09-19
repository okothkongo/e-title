defmodule ETitleWeb.Admin.AccountLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Accounts
  alias Phoenix.Naming

  def mount(_params, _session, socket) do
    accounts = Accounts.list_accounts_with_user_and_role()

    {:ok, stream(socket, :accounts, accounts)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <h1 class="text-2xl font-bold mb-6 text-green-700 text-center">User Accounts</h1>

          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <.table
              id="accounts"
              rows={@streams.accounts}
            >
              <:col
                :let={{_id, account}}
                label="Name"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">
                  {"#{account.user.first_name}#{if account.user.middle_name, do: " " <> account.user.middle_name, else: ""} #{account.user.surname}"}
                </span>
              </:col>

              <:col
                :let={{_id, account}}
                label="Email"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{account.email}</span>
              </:col>

              <:col
                :let={{_id, account}}
                label="Phone"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-600">{account.phone_number}</span>
              </:col>

              <:col
                :let={{_id, account}}
                label="Type"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{account.type}</span>
              </:col>

              <:col
                :let={{_id, account}}
                label="Role"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">
                  {Naming.humanize(account.account_role.role.name)}
                </span>
              </:col>

              <:col
                :let={{_id, account}}
                label="Confirmed"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm font-medium text-gray-900">
                  {account.confirmed_at || "Not confirmed"}
                </span>
              </:col>

              <:col
                :let={{_id, account}}
                label="Status"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm font-medium text-gray-900">{account.status}</span>
              </:col>

              <:action :let={{id, account}}>
                <%= if account.status == :active do %>
                  <.link
                    phx-click={JS.push("deactivate", value: %{id: account.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                    class="text-red-600 hover:text-red-900"
                  >
                    Deactivate
                  </.link>
                <% else %>
                  <.link
                    phx-click={JS.push("activate", value: %{id: account.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                    class="text-green-700 hover:text-green-900"
                  >
                    Activate
                  </.link>
                <% end %>
              </:action>
            </.table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("deactivate", %{"id" => id}, socket) do
    account = Accounts.get_account(id)

    {:ok, _account} =
      Accounts.update_account(account, %{status: :inactive})

    {:noreply, socket |> stream_insert(:accounts, account) |> push_patch(to: ~p"/admin/accounts")}
  end

  def handle_event("activate", %{"id" => id}, socket) do
    account = Accounts.get_account(id)

    {:ok, account} =
      Accounts.update_account(account, %{status: :active})

    {:noreply, socket |> stream_insert(:accounts, account) |> push_patch(to: ~p"/admin/accounts")}
  end
end
