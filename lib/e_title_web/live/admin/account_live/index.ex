defmodule ETitleWeb.Admin.AccountLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  def mount(_params, _session, socket) do
    accounts = Accounts.list_accounts_with_user_and_role()
    {:ok, assign(socket, accounts: accounts)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <h1 class="text-2xl font-bold mb-6 text-green-700 text-center">User Accounts</h1>

          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <table class="min-w-full divide-y divide-green-200">
              <thead class="bg-green-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Phone Number
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Type
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Role
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Confirmed At
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-green-200">
                <%= for account <- @accounts do %>
                  <tr class="hover:bg-green-50 transition-colors duration-150">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {"#{account.user.first_name}#{account.user.middle_name} #{account.user.surname}"}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {account.email}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                      {account.phone_number}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{account.type}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {Phoenix.Naming.humanize(account.account_role.role.name)}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {account.confirmed_at || "Not confirmed"}
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
