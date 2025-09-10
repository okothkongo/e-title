defmodule ETitleWeb.Admin.UserLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    {:ok, assign(socket, users: users)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <h1 class="text-2xl font-bold mb-6 text-green-700 text-center">User List</h1>

          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <table class="min-w-full divide-y divide-green-200">
              <thead class="bg-green-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    First Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Middle Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Surname
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    ID Number
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-green-200">
                <%= for user <- @users do %>
                  <tr class="hover:bg-green-50 transition-colors duration-150">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {user.first_name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                      {user.middle_name || "-"}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.surname}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {user.identity_doc_no}
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
