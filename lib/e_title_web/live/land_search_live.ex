defmodule ETitleWeb.LandSearchLive do
  use ETitleWeb, :live_view

  alias ETitle.Lands

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50 py-8">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-8">
            <.header>
              <h1 class="text-3xl font-bold text-gray-900">Land Title Search</h1>
              <:subtitle>Search for land details using the title deed number</:subtitle>
            </.header>
          </div>

          <div class="bg-white rounded-lg shadow-md p-6 mb-8">
            <.form for={@form} id="land-search-form" phx-submit="search">
              <div class="flex gap-4">
                <div class="flex-1">
                  <.input
                    field={@form[:title_number]}
                    type="text"
                    label="Title Deed Number"
                    placeholder="Enter title deed number"
                    required
                    class="w-full"
                  />
                </div>
                <div class="flex items-end">
                  <.button type="submit" variant="primary" class="px-8">
                    <.icon name="hero-magnifying-glass" class="w-5 h-5 mr-2" /> Search
                  </.button>
                </div>
              </div>
            </.form>
          </div>

          <%= if @search_result do %>
            <div class="bg-white rounded-lg shadow-md overflow-hidden">
              <div class="px-6 py-4 bg-green-50 border-b border-green-200">
                <h2 class="text-xl font-semibold text-green-800">Land Details Found</h2>
              </div>

              <div class="p-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div class="space-y-4">
                    <h3 class="text-lg font-medium text-gray-900 border-b border-gray-200 pb-2">
                      Owner Information
                    </h3>
                    <div class="space-y-3">
                      <div>
                        <span class="text-sm font-medium text-gray-500">Full Name:</span>
                        <p class="text-gray-900">
                          {@search_result.account.user.first_name}
                          <%= if @search_result.account.user.middle_name do %>
                            {@search_result.account.user.middle_name}
                          <% end %>
                          {@search_result.account.user.surname}
                        </p>
                      </div>
                      <div>
                        <span class="text-sm font-medium text-gray-500">
                          Identity Document Number:
                        </span>
                        <p class="text-gray-900">{@search_result.account.user.identity_doc_no}</p>
                      </div>
                    </div>
                  </div>

                  <div class="space-y-4">
                    <h3 class="text-lg font-medium text-gray-900 border-b border-gray-200 pb-2">
                      Land Information
                    </h3>
                    <div class="space-y-3">
                      <div>
                        <span class="text-sm font-medium text-gray-500">Title Number:</span>
                        <p class="text-gray-900 font-mono">{@search_result.title_number}</p>
                      </div>
                      <div>
                        <span class="text-sm font-medium text-gray-500">Size:</span>
                        <p class="text-gray-900">{@search_result.size} acres</p>
                      </div>
                      <div>
                        <span class="text-sm font-medium text-gray-500">GPS Coordinates:</span>
                        <p class="text-gray-900 font-mono">{@search_result.gps_cordinates}</p>
                      </div>
                      <div>
                        <span class="text-sm font-medium text-gray-500">Registry:</span>
                        <p class="text-gray-900">{@search_result.registry.name}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          <% end %>

          <%= if @search_error do %>
            <div class="bg-red-50 border border-red-200 rounded-lg p-6">
              <div class="flex">
                <div class="flex-shrink-0">
                  <.icon name="hero-exclamation-triangle" class="h-5 w-5 text-red-400" />
                </div>
                <div class="ml-3">
                  <h3 class="text-sm font-medium text-red-800">Search Error</h3>
                  <div class="mt-2 text-sm text-red-700">
                    <p>{@search_error}</p>
                  </div>
                </div>
              </div>
            </div>
          <% end %>

          <%= if @search_performed && is_nil(@search_result) && is_nil(@search_error) do %>
            <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
              <div class="flex">
                <div class="flex-shrink-0">
                  <.icon name="hero-information-circle" class="h-5 w-5 text-yellow-400" />
                </div>
                <div class="ml-3">
                  <h3 class="text-sm font-medium text-yellow-800">No Results Found</h3>
                  <div class="mt-2 text-sm text-yellow-700">
                    <p>
                      No land found with the provided title deed number. Please verify the number and try again.
                    </p>
                  </div>
                </div>
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
    form = to_form(%{"title_number" => ""}, as: :search)

    {:ok,
     socket
     |> assign(:page_title, "Land Title Search")
     |> assign(:form, form)
     |> assign(:search_result, nil)
     |> assign(:search_error, nil)
     |> assign(:search_performed, false)}
  end

  @impl true
  def handle_event("search", %{"search" => %{"title_number" => title_number}}, socket) do
    case Lands.search_land_by_title_number(title_number) do
      {:ok, land} ->
        {:noreply,
         socket
         |> assign(:search_result, land)
         |> assign(:search_error, nil)
         |> assign(:search_performed, true)}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> assign(:search_result, nil)
         |> assign(:search_error, nil)
         |> assign(:search_performed, true)}

      {:error, :invalid_input} ->
        {:noreply,
         socket
         |> assign(:search_result, nil)
         |> assign(:search_error, "Please enter a valid title deed number")
         |> assign(:search_performed, true)}
    end
  end
end
