defmodule ETitleWeb.NavbarLive do
  use ETitleWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, mobile_menu_open: false)}
  end

  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: !socket.assigns.mobile_menu_open)}
  end

  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: false)}
  end

  def render(assigns) do
    ~H"""
    <nav class="bg-white/95 backdrop-blur-md shadow-xl border-b border-gray-200/50 fixed w-full top-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <!-- Logo -->
          <div class="flex items-center">
            <div class="flex-shrink-0 flex items-center">
              <svg
                class="h-6 w-6 sm:h-8 sm:w-8 text-green-600 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                >
                </path>
              </svg>
              <span class="text-lg sm:text-2xl font-bold text-green-800">E-Title</span>
            </div>
          </div>
          
    <!-- Desktop Navigation -->
          <div class="hidden lg:flex items-center space-x-6 xl:space-x-8">
            <.link
              href={~p"/"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-300 hover:bg-green-50 hover:scale-105"
            >
              Home
            </.link>
            <.link
              href={~p"/#about"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-300 hover:bg-green-50 hover:scale-105"
            >
              About Us
            </.link>
            <.link
              href={~p"/#contact"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-300 hover:bg-green-50 hover:scale-105"
            >
              Contact Us
            </.link>

            <%= if @current_scope && @current_scope.account do %>
              <!-- Authenticated user links -->
              <.link
                href={~p"/accounts/settings"}
                class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Settings
              </.link>
              <.link
                href={~p"/accounts/log-out"}
                method="delete"
                class="bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white px-4 xl:px-6 py-2 rounded-lg text-sm font-medium transition-all duration-300 shadow-lg hover:shadow-xl transform hover:scale-105 inline-block cursor-pointer"
              >
                Logout
              </.link>
            <% else %>
              <!-- Unauthenticated user links -->
              <.link
                href={~p"/accounts/register"}
                class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-300 hover:bg-green-50 hover:scale-105"
              >
                Register
              </.link>
              <.link
                href={~p"/accounts/log-in"}
                class="bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white px-4 xl:px-6 py-2 rounded-lg text-sm font-medium transition-all duration-300 shadow-lg hover:shadow-xl transform hover:scale-105"
              >
                Login
              </.link>
            <% end %>
          </div>
          
    <!-- Mobile menu button -->
          <div class="lg:hidden">
            <button
              phx-click="toggle_mobile_menu"
              phx-target={@myself}
              data-mobile-menu-button
              class="text-gray-700 hover:text-green-600 focus:outline-none focus:text-green-600 p-2"
              aria-label="Toggle mobile menu"
            >
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d={
                    if @mobile_menu_open,
                      do: "M6 18L18 6M6 6l12 12",
                      else: "M4 6h16M4 12h16M4 18h16"
                  }
                >
                </path>
              </svg>
            </button>
          </div>
        </div>
        
    <!-- Mobile Navigation Menu -->
        <div
          data-mobile-menu
          class={[
            "lg:hidden transition-all duration-300 ease-in-out",
            if(@mobile_menu_open,
              do: "max-h-96 opacity-100",
              else: "max-h-0 opacity-0 overflow-hidden"
            )
          ]}
        >
          <div class="px-2 pt-2 pb-3 space-y-1 bg-white border-t border-gray-200">
            <a
              href="/"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
            >
              Home
            </a>
            <a
              href="/#about"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
            >
              About Us
            </a>
            <a
              href="/#contact"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
            >
              Contact Us
            </a>

            <%= if @current_scope && @current_scope.account do %>
              <!-- Authenticated user mobile links -->
              <a
                href="/accounts/settings"
                phx-click="close_mobile_menu"
                phx-target={@myself}
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
              >
                Settings
              </a>
              <.link
                href={~p"/accounts/log-out"}
                method="delete"
                phx-click="close_mobile_menu"
                phx-target={@myself}
                class="block px-3 py-2 text-base font-medium bg-red-600 text-white hover:bg-red-700 rounded-md transition-colors text-center"
              >
                Logout
              </.link>
            <% else %>
              <!-- Unauthenticated user mobile links -->
              <a
                href="/accounts/register"
                phx-click="close_mobile_menu"
                phx-target={@myself}
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
              >
                Register
              </a>
              <a
                href="/accounts/log_in"
                phx-click="close_mobile_menu"
                phx-target={@myself}
                class="block px-3 py-2 text-base font-medium bg-green-600 text-white hover:bg-green-700 rounded-md transition-colors text-center"
              >
                Login
              </a>
            <% end %>
          </div>
        </div>
      </div>
    </nav>
    """
  end
end
