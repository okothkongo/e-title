defmodule ETitleWeb.Admin.UserLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    {:ok, stream(socket, :users, users)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <div class="relative flex justify-center items-center mb-6">
            <.header>
              <h1 class="text-2xl font-bold text-green-700">Users</h1>
            </.header>
          </div>

          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <.table
              id="users"
              rows={@streams.users}
            >
              <:col
                :let={{_id, user}}
                label="First Name"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{user.first_name}</span>
              </:col>

              <:col
                :let={{_id, user}}
                label="Middle Name"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-600">{user.middle_name || "-"}</span>
              </:col>

              <:col
                :let={{_id, user}}
                label="Surname"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{user.surname}</span>
              </:col>

              <:col
                :let={{_id, user}}
                label="ID Number"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm font-medium text-gray-900">{user.identity_doc_no}</span>
              </:col>
            </.table>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
