defmodule ETitleWeb.Admin.RegistryLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Locations

  def mount(_params, _session, socket) do
    registries = Locations.list_registry_with_county_and_sub_county()
    {:ok, assign(socket, registries: registries)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <h1 class="text-2xl font-bold mb-6 text-green-700 text-center">Registry List</h1>
          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <table class="min-w-full divide-y divide-green-200">
              <thead class="bg-green-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Phone Number
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    County
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider">
                    Sub County
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-green-200">
                <%= for registry <- @registries do %>
                  <tr class="hover:bg-green-50 transition-colors duration-150">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {registry.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                      {registry.phone_number || "-"}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {registry.email}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {registry.county.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {registry.sub_county.name}
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
