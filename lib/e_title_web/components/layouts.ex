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
  alias ETitle.Accounts

  @doc """
   Renders the dashboard layout with sidebar navigation.

   This layout is specifically designed for the dashboard and includes
   a sidebar navigation and main content area.

   ## Examples

      <Layouts.dashboard flash={@flash}>
        <h1>Dashboard Content</h1>
      </Layouts.dashboard>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, default: nil, doc: "the current scope"

  slot :inner_block, required: true

  def dashboard(assigns) do
    ~H"""
    <div class="min-h-full bg-gray-100">
      {render_slot(@inner_block)}
    </div>
    <.flash_group flash={@flash} />
    """
  end

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
    <main class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 pt-20 pb-32">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-6 sm:p-8 lg:p-12 my-8">
          {render_slot(@inner_block)}
        </div>
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
  Renders the footer section.
  """
  def footer(assigns) do
    ~H"""
    <footer class="bg-gradient-to-r from-gray-900 via-gray-800 to-gray-900 text-white border-t border-gray-700/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
          <!-- Company Info -->
          <div class="sm:col-span-2 lg:col-span-2">
            <div class="flex items-center mb-3 sm:mb-4">
              <svg
                class="h-6 w-6 sm:h-8 sm:w-8 text-green-400 mr-2"
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
              <span class="text-xl sm:text-2xl font-bold">E-Title</span>
            </div>
            <p class="text-sm sm:text-base text-gray-300 mb-4 sm:mb-6 max-w-md leading-relaxed">
              Transforming land registration through digital innovation. Secure, transparent,
              and efficient land title management for the modern era.
            </p>
            <div class="flex space-x-4">
              <!-- Social Media Links -->
              <a
                href="https://facebook.com/etitle"
                class="text-gray-300 hover:text-green-400 transition-colors p-1"
                aria-label="Facebook"
              >
                <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                </svg>
              </a>
              <a
                href="https://x.com/etitle"
                class="text-gray-300 hover:text-green-400 transition-colors p-1"
                aria-label="X (Twitter)"
              >
                <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                </svg>
              </a>
              <a
                href="https://linkedin.com/company/etitle"
                class="text-gray-300 hover:text-green-400 transition-colors p-1"
                aria-label="LinkedIn"
              >
                <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
                </svg>
              </a>
            </div>
          </div>
          
    <!-- Quick Links -->
          <div>
            <h3 class="text-base sm:text-lg font-semibold mb-3 sm:mb-4">Quick Links</h3>
            <ul class="space-y-2">
              <li>
                <a
                  href="/"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Home
                </a>
              </li>
              <li>
                <a
                  href="/#about"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  About Us
                </a>
              </li>
              <li>
                <a
                  href="/#contact"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Contact Us
                </a>
              </li>
              <li>
                <a
                  href="/accounts/register"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Register
                </a>
              </li>
              <li>
                <a
                  href="/privacy"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Privacy Policy
                </a>
              </li>
              <li>
                <a
                  href="/terms"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Terms of Service
                </a>
              </li>
            </ul>
          </div>
          
    <!-- Services -->
          <div>
            <h3 class="text-base sm:text-lg font-semibold mb-3 sm:mb-4">Services</h3>
            <ul class="space-y-2">
              <li>
                <a
                  href="/services/registration"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Land Registration
                </a>
              </li>
              <li>
                <a
                  href="/services/search"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Title Search
                </a>
              </li>
              <li>
                <a
                  href="/services/transfer"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Property Transfer
                </a>
              </li>
              <li>
                <a
                  href="/services/verification"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Document Verification
                </a>
              </li>
              <li>
                <a
                  href="/support"
                  class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                >
                  Support Center
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div class="border-t border-gray-700 mt-6 sm:mt-8 pt-6 sm:pt-8 text-center">
          <p class="text-xs sm:text-sm text-gray-300 leading-relaxed">
            © {DateTime.utc_now().year} E-Title. All rights reserved. | Government of Kenya - Ministry of Lands and Physical Planning
          </p>
        </div>
      </div>
    </footer>
    """
  end

  def unauthenticated_navbar(assigns) do
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
                />
              </svg>
              <span class="text-lg sm:text-2xl font-bold text-green-800">E-Title</span>
            </div>
          </div>
          
    <!-- Desktop Navigation -->
          <div class="hidden lg:flex items-center space-x-6 xl:space-x-8">
            <.link
              href={~p"/"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium"
            >
              Home
            </.link>
            <.link
              href={~p"/#about"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium"
            >
              About
            </.link>
            <.link
              href={~p"/#contact"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium"
            >
              Contact
            </.link>
            <.link
              href={~p"/accounts/register"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg text-sm font-medium"
            >
              Register
            </.link>
            <.link
              href={~p"/accounts/log-in"}
              class="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium"
            >
              Login
            </.link>
          </div>
          
    <!-- Mobile Menu Button -->
          <div class="lg:hidden">
            <button
              phx-click={JS.toggle_class("hidden", to: "#mobile-menu")}
              class="text-gray-700 hover:text-green-600 p-2"
            >
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
      
    <!-- Mobile Menu -->
      <div
        id="mobile-menu"
        class="hidden lg:hidden px-2 pt-2 pb-3 space-y-1 bg-white border-t border-gray-200"
      >
        <.link
          href="/"
          class="block px-3 py-2 rounded-md text-base font-medium text-gray-700 hover:bg-green-50"
        >
          Home
        </.link>
        <.link
          href="/#about"
          class="block px-3 py-2 rounded-md text-base font-medium text-gray-700 hover:bg-green-50"
        >
          About
        </.link>
        <.link
          href="/#contact"
          class="block px-3 py-2 rounded-md text-base font-medium text-gray-700 hover:bg-green-50"
        >
          Contact
        </.link>
        <.link
          href={~p"/accounts/register"}
          class="block px-3 py-2 text-gray-700 hover:bg-green-50 rounded-md"
        >
          Register
        </.link>
        <.link
          href={~p"/accounts/log-in"}
          class="block px-3 py-2 bg-green-600 text-white rounded-md text-center"
        >
          Login
        </.link>
      </div>
    </nav>
    """
  end

  def authenticated_navbar(assigns) do
    ~H"""
    <div
      role="dialog"
      aria-modal="true"
      class={["relative z-40 lg:hidden", if(false, do: "block", else: "hidden")]}
    >
      <div aria-hidden="true" class="fixed inset-0 bg-gray-600/75"></div>
      <div class="fixed inset-0 z-40 flex">
        <div class="relative flex w-full max-w-xs flex-1 flex-col bg-green-700 pt-5 pb-4">
          <div class="absolute top-0 right-0 -mr-12 pt-2">
            <button
              type="button"
              phx-click="close_mobile_menu"
              class="relative ml-1 flex size-10 items-center justify-center rounded-full focus:ring-2 focus:ring-white focus:outline-hidden focus:ring-inset"
            >
              <span class="absolute -inset-0.5"></span>
              <span class="sr-only">Close sidebar</span>
              <.icon name="hero-x-mark" class="size-6 text-white" />
            </button>
          </div>

          <div class="flex shrink-0 items-center px-4">
            <svg
              class="h-8 w-auto text-green-300"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
              />
            </svg>
            <span class="ml-2 text-xl font-bold text-white">E-Title</span>
          </div>

          <nav
            aria-label="Sidebar"
            class="mt-5 h-full shrink-0 divide-y divide-green-800 overflow-y-auto"
          >
            <div class="space-y-1 px-2">
              <a
                href={~p"/admin/dashboard"}
                aria-current="page"
                class="group flex items-center rounded-md bg-green-800 px-2 py-2 text-base font-medium text-white"
              >
                <.icon name="hero-home" class="mr-4 size-6 shrink-0 text-green-200" /> Dashboard
              </a>

              <.link
                navigate={~p"/admin/users"}
                class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-document-text" class="mr-4 size-6 shrink-0 text-green-200" /> Users
              </.link>
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-magnifying-glass" class="mr-4 size-6 shrink-0 text-green-200" />
                Search
              </a>
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon
                  name="hero-arrow-right-arrow-left"
                  class="mr-4 size-6 shrink-0 text-green-200"
                /> Transfers
              </a>
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-shield-check" class="mr-4 size-6 shrink-0 text-green-200" />
                Verification
              </a>
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-chart-bar" class="mr-4 size-6 shrink-0 text-green-200" /> Reports
              </a>
            </div>
            <div class="mt-6 pt-6">
              <div class="space-y-1 px-2">
                <a
                  href="#"
                  class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
                >
                  <.icon name="hero-cog-6-tooth" class="mr-4 size-6 text-green-200" /> Settings
                </a>
                <a
                  href="#"
                  class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
                >
                  <.icon name="hero-question-mark-circle" class="mr-4 size-6 text-green-200" /> Help
                </a>
                <a
                  href="#"
                  class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
                >
                  <.icon name="hero-shield-check" class="mr-4 size-6 text-green-200" /> Privacy
                </a>
              </div>
            </div>
          </nav>
        </div>
        <div aria-hidden="true" class="w-14 shrink-0"></div>
      </div>
    </div>

    <!-- Static sidebar for desktop -->
    <div class="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col">
      <div class="flex grow flex-col overflow-y-auto bg-green-800 pt-5">
        <div class="flex shrink-0 items-center px-4">
          <svg
            class="h-8 w-auto text-green-300"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
            />
          </svg>
          <span class="ml-2 text-xl font-bold text-white">E-Title</span>
        </div>
        <nav
          aria-label="Sidebar"
          class="mt-5 flex flex-1 flex-col divide-y divide-green-800 overflow-y-auto"
        >
          <div class="space-y-1 px-2">
            <a
              href="#"
              aria-current="page"
              class="group flex items-center rounded-md bg-green-900 px-2 py-2 text-sm/6 font-medium text-white"
            >
              <.icon name="hero-home" class="mr-4 size-6 shrink-0 text-green-200" /> Dashboard
            </a>
            <%= if Accounts.admin?(@current_scope.account) do %>
              <.link
                navigate={~p"/admin/users"}
                class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-document-text" class="mr-4 size-6 shrink-0 text-green-200" /> Users
              </.link>
            <% end %>
            <a
              href="#"
              class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
            >
              <.icon name="hero-magnifying-glass" class="mr-4 size-6 shrink-0 text-green-200" />
              Search
            </a>
            <a
              href="#"
              class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
            >
              <.icon
                name="hero-arrow-right-arrow-left"
                class="mr-4 size-6 shrink-0 text-green-200"
              /> Transfers
            </a>
            <a
              href="#"
              class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
            >
              <.icon name="hero-shield-check" class="mr-4 size-6 shrink-0 text-green-200" />
              Verification
            </a>
            <a
              href="#"
              class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
            >
              <.icon name="hero-chart-bar" class="mr-4 size-6 shrink-0 text-green-200" /> Reports
            </a>
          </div>
          <div class="mt-6 pt-6">
            <div class="space-y-1 px-2">
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-cog-6-tooth" class="mr-4 size-6 text-green-200" /> Settings
              </a>
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-question-mark-circle" class="mr-4 size-6 text-green-200" /> Help
              </a>
              <a
                href="#"
                class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
              >
                <.icon name="hero-shield-check" class="mr-4 size-6 text-green-200" /> Privacy
              </a>
            </div>
          </div>
        </nav>
        <!-- Profile dropdown -->
        <div class="border-t border-green-700 p-4">
          <div class="relative">
            <button
              type="button"
              phx-click="toggle_profile_menu"
              class="flex w-full items-center gap-x-4 px-2 py-2 text-sm/6 font-semibold text-white hover:bg-green-600 hover:text-white rounded-md"
            >
              <img
                src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                alt={get_user_name(@current_scope.account.user_id)}
                class="size-8 rounded-full bg-gray-800 outline -outline-offset-1 outline-white/10"
              />
              <span class="sr-only">Your profile</span>
              <span aria-hidden="true" class="flex-1 text-left">
                {get_user_name(@current_scope.account.user_id)}
              </span>
              <.icon name="hero-chevron-up-down" class="size-5 text-green-200" />
            </button>

            <div
              :if={true}
              class="absolute bottom-full left-0 z-10 mb-2 w-full overflow-hidden rounded-md bg-white shadow-lg"
            >
              <div class="py-1">
                <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  Your Profile
                </a>
                <.link
                  href={~p"/accounts/settings"}
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Settings
                </.link>
                <.link
                  href={~p"/accounts/log-out"}
                  method="delete"
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Sign out
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_user_name(user_id) do
    user = ETitle.Accounts.get_user(user_id)
    "#{user.first_name} #{user.surname}"
  end
end
