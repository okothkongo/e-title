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
    <.live_component module={ETitleWeb.NavbarLive} id="navbar" current_scope={@current_scope} />

    <main class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 pt-20 pb-32">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-6 sm:p-8 lg:p-12 my-8">
          {render_slot(@inner_block)}
        </div>
      </div>
    </main>

    <.footer />
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
end
