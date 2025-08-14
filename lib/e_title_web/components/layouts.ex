defmodule ETitleWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ETitleWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  attr :class, :string, default: "", doc: "Additional classes for nav links"

  def nav_links(assigns) do
    ~H"""
    <a href={~p"/"} class={["hover:underline", @class]}>Home</a>
    <a href="#" class={["hover:underline", @class]}>Register Land</a>
    <a href="#" class={["hover:underline", @class]}>Search Title</a>
    <a href="#" class={["hover:underline", @class]}>Help</a>
    <a href="#" class={["hover:underline", @class]}>Contact</a>
    """
  end

  attr :current_scope, :map, required: true
  attr :is_mobile, :boolean, default: false

  def user_dropdown(assigns) do
    ~H"""
    <div class="relative">
      <button
        phx-click={
          JS.toggle(to: "##{if(@is_mobile, do: "mobile-user-dropdown", else: "user-dropdown")}")
        }
        class={[
          "flex items-center space-x-2 px-3 py-2 rounded",
          if(@is_mobile,
            do: "w-full justify-between bg-green-500 hover:bg-green-400",
            else: "bg-green-600 hover:bg-green-500"
          )
        ]}
      >
        <span>
          {@current_scope.user.first_name} {@current_scope.user.middle_name} {@current_scope.user.surname}
        </span>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      <div
        id={if @is_mobile, do: "mobile-user-dropdown", else: "user-dropdown"}
        class={[
          "hidden bg-white text-gray-800 rounded shadow-lg overflow-hidden",
          if(@is_mobile, do: "mt-1", else: "absolute right-0 mt-2 w-40")
        ]}
        phx-click-away={
          JS.hide(to: "##{if(@is_mobile, do: "mobile-user-dropdown", else: "user-dropdown")}")
        }
      >
        <.link href={~p"/users/settings"} class="block px-4 py-2 hover:bg-gray-100">Profile</.link>
        <.link href={~p"/users/log-out"} method="delete" class="block px-4 py-2 hover:bg-gray-100">
          Log out
        </.link>
      </div>
    </div>
    """
  end

  attr :is_mobile, :boolean, default: false

  def auth_buttons(assigns) do
    ~H"""
    <a
      href={~p"/users/log-in"}
      class={[
        "bg-white text-green-700 px-4 py-2 rounded hover:bg-gray-100",
        if(@is_mobile, do: "text-center", else: "")
      ]}
    >
      Login
    </a>
    <a
      href={~p"/users/register"}
      class={[
        "bg-yellow-400 text-green-900 px-4 py-2 rounded hover:bg-yellow-300",
        if(@is_mobile, do: "text-center", else: "")
      ]}
    >
      Register
    </a>
    """
  end

  def navbar(assigns) do
    ~H"""
    <header class="bg-green-700 text-white shadow relative">
      <div class="container mx-auto flex justify-between items-center p-4">
        <h1 class="text-2xl font-bold">E-Title</h1>
        <button
          phx-click={JS.toggle(to: "#mobile-menu")}
          class="md:hidden focus:outline-none"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
        <!-- Desktop Menu -->
        <nav class="hidden md:flex space-x-6 items-center">
          <.nav_links />
          <%= if @current_scope do %>
            <.user_dropdown current_scope={@current_scope} />
          <% else %>
            <.auth_buttons />
          <% end %>
          <.theme_toggle />
        </nav>
      </div>
      <!-- Mobile Menu -->
      <div
        id="mobile-menu"
        class="hidden bg-green-600 md:hidden"
        phx-click-away={JS.hide(to: "#mobile-menu")}
      >
        <nav class="flex flex-col p-4 space-y-3">
          <.nav_links class="block" />
          <hr class="border-green-500" />
          <%= if @current_scope do %>
            <.user_dropdown current_scope={@current_scope} is_mobile={true} />
          <% else %>
            <.auth_buttons is_mobile={true} />
          <% end %>
        </nav>
        <.theme_toggle />
      </div>
    </header>
    """
  end

  def footer(assigns) do
    ~H"""
    <!-- Footer -->
    <footer class="bg-green-900 text-white py-12">
      <div class="max-w-7xl mx-auto px-4">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h5 class="font-semibold text-lg mb-4">E-Title Kenya</h5>
            <p class="text-green-200 text-sm">
              Your trusted partner in digital land title management and registration services.
            </p>
          </div>
          <div>
            <h5 class="font-semibold text-lg mb-4">Quick Links</h5>
            <ul class="space-y-2 text-green-200">
              <li><a href="#services" class="hover:text-white transition">Services</a></li>
              <li><a href="#about" class="hover:text-white transition">About Us</a></li>
              <li><a href="#contact" class="hover:text-white transition">Contact</a></li>
              <li><a href="#search" class="hover:text-white transition">Search Title</a></li>
            </ul>
          </div>
          <div>
            <h5 class="font-semibold text-lg mb-4">Legal</h5>
            <ul class="space-y-2 text-green-200">
              <li><a href="#" class="hover:text-white transition">Privacy Policy</a></li>
              <li><a href="#" class="hover:text-white transition">Terms of Service</a></li>
              <li><a href="#" class="hover:text-white transition">Disclaimer</a></li>
            </ul>
          </div>
          <div>
            <h5 class="font-semibold text-lg mb-4">Follow Us</h5>
            <div class="flex space-x-4">
              <a href="#" class="text-green-200 hover:text-white transition">
                <span class="sr-only">Facebook</span>
                <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z" />
                </svg>
              </a>
              <a href="#" class="text-green-200 hover:text-white transition">
                <span class="sr-only">Twitter</span>
                <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z" />
                </svg>
              </a>
              <a href="#" class="text-green-200 hover:text-white transition">
                <span class="sr-only">LinkedIn</span>
                <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
                </svg>
              </a>
            </div>
          </div>
        </div>
        <div class="border-t border-green-800 mt-8 pt-8 text-center text-green-200 text-sm">
          <p>&copy; {DateTime.utc_now().year} E-Title Kenya. All rights reserved.</p>
        </div>
      </div>
    </footer>
    """
  end
end
