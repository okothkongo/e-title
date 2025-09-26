defmodule ETitleWeb.Admin.RegistryLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Locations

  def mount(_params, _session, socket) do
    registries = Locations.list_registry_with_county_and_sub_county()
    {:ok, stream(socket, :registries, registries)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <div class="flex flex-1 flex-col lg:pl-64">
        <div class="p-6">
          <div class="relative flex justify-center items-center mb-6">
            <.header>
              <h1 class="text-2xl font-bold text-green-700">Registries</h1>
              <:actions>
                <.link navigate={~p"/admin/registries/new"}>
                  <.button>Create Registry</.button>
                </.link>
              </:actions>
            </.header>
          </div>

          <div class="overflow-x-auto bg-white rounded-lg shadow-md">
            <.table
              id="registries"
              rows={@streams.registries}
            >
              <:col
                :let={{_id, registry}}
                label="Name"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{registry.name}</span>
              </:col>

              <:col
                :let={{_id, registry}}
                label="Phone Number"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-600">{registry.phone_number || "-"}</span>
              </:col>

              <:col
                :let={{_id, registry}}
                label="Email"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm text-gray-900">{registry.email}</span>
              </:col>

              <:col
                :let={{_id, registry}}
                label="County"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm font-medium text-gray-900">{registry.county.name}</span>
              </:col>

              <:col
                :let={{_id, registry}}
                label="Sub County"
                class="px-6 py-3 text-left text-xs font-medium text-green-700 uppercase tracking-wider"
              >
                <span class="text-sm font-medium text-gray-900">{registry.sub_county.name}</span>
              </:col>
            </.table>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
