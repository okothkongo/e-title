defmodule ETitleWeb.Admin.DashboardLive do
  use ETitleWeb, :live_view
  alias ETitle.Accounts

  def mount(_params, _session, socket) do
    dashboard_data = %{
      user: %{
        name: "John Doe",
        email: "john.doe@example.com",
        avatar:
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
        company: "Land Registry Office",
        status: "Verified Account"
      },
      stats: %{
        total_registrations: 1247,
        pending_approvals: 23,
        completed_this_month: 89,
        total_revenue: 125_000
      },
      recent_activities: [
        %{
          id: 1,
          type: "registration",
          title: "New Land Registration",
          description: "Property registration for Plot No. 12345",
          amount: 5000,
          status: "completed",
          date: "2024-01-15"
        },
        %{
          id: 2,
          type: "transfer",
          title: "Property Transfer",
          description: "Transfer of ownership for Plot No. 67890",
          amount: 3000,
          status: "pending",
          date: "2024-01-14"
        },
        %{
          id: 3,
          type: "search",
          title: "Title Search",
          description: "Search request for Plot No. 11111",
          amount: 500,
          status: "completed",
          date: "2024-01-13"
        },
        %{
          id: 4,
          type: "verification",
          title: "Document Verification",
          description: "Verification of ownership documents",
          amount: 1000,
          status: "processing",
          date: "2024-01-12"
        },
        %{
          id: 5,
          type: "registration",
          title: "New Land Registration",
          description: "Property registration for Plot No. 22222",
          amount: 5000,
          status: "completed",
          date: "2024-01-11"
        }
      ]
    }

    {:ok,
     assign(socket,
       dashboard_data: dashboard_data,
       mobile_menu_open: false,
       profile_menu_open: false
     )}
  end

  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: !socket.assigns.mobile_menu_open)}
  end

  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: false)}
  end

  def handle_event("toggle_profile_menu", _params, socket) do
    {:noreply, assign(socket, profile_menu_open: !socket.assigns[:profile_menu_open])}
  end

  def render(assigns) do
    ~H"""
    <Layouts.dashboard flash={@flash} current_scope={@current_scope}>
      <div class="min-h-full">
        <!-- Off-canvas menu for mobile -->
        <div
          role="dialog"
          aria-modal="true"
          class={["relative z-40 lg:hidden", if(@mobile_menu_open, do: "block", else: "hidden")]}
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
                    href="#"
                    aria-current="page"
                    class="group flex items-center rounded-md bg-green-800 px-2 py-2 text-base font-medium text-white"
                  >
                    <.icon name="hero-home" class="mr-4 size-6 shrink-0 text-green-200" /> Dashboard
                  </a>
                  <a
                    href="#"
                    class="group flex items-center rounded-md px-2 py-2 text-base font-medium text-green-100 hover:bg-green-600 hover:text-white"
                  >
                    <.icon name="hero-document-text" class="mr-4 size-6 shrink-0 text-green-200" />
                    Registrations
                  </a>
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
                    <.icon name="hero-chart-bar" class="mr-4 size-6 shrink-0 text-green-200" />
                    Reports
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
                      <.icon name="hero-question-mark-circle" class="mr-4 size-6 text-green-200" />
                      Help
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
                <a
                  href="#"
                  class="group flex items-center rounded-md px-2 py-2 text-sm/6 font-medium text-green-100 hover:bg-green-600 hover:text-white"
                >
                  <.icon name="hero-document-text" class="mr-4 size-6 shrink-0 text-green-200" />
                  Registrations
                </a>
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
                    src={@dashboard_data.user.avatar}
                    alt={@dashboard_data.user.name}
                    class="size-8 rounded-full bg-gray-800 outline -outline-offset-1 outline-white/10"
                  />
                  <span class="sr-only">Your profile</span>
                  <span aria-hidden="true" class="flex-1 text-left">{@dashboard_data.user.name}</span>
                  <.icon name="hero-chevron-up-down" class="size-5 text-green-200" />
                </button>

                <div
                  :if={@profile_menu_open}
                  class="absolute bottom-full left-0 z-10 mb-2 w-full overflow-hidden rounded-md bg-white shadow-lg"
                >
                  <div class="py-1">
                    <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                      Your Profile
                    </a>
                    <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                      Settings
                    </a>
                    <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                      Sign out
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="flex flex-1 flex-col lg:pl-64">
          
    <!-- Main content -->
          <main class="flex-1 pb-8">
            <!-- Page header -->
            <div class="bg-white shadow-sm">
              <div class="px-4 sm:px-6 lg:mx-auto lg:max-w-6xl lg:px-8">
                <div class="py-6 md:flex md:items-center md:justify-between lg:border-t lg:border-gray-200">
                  <div class="min-w-0 flex-1">
                    <div class="flex items-center">
                      <img
                        src={@dashboard_data.user.avatar}
                        alt=""
                        class="hidden size-16 rounded-full sm:block"
                      />
                      <div>
                        <div class="flex items-center">
                          <img
                            src={@dashboard_data.user.avatar}
                            alt=""
                            class="size-16 rounded-full sm:hidden"
                          />
                          <h1 class="ml-3 text-2xl/7 font-bold text-gray-900 sm:truncate sm:text-2xl/9">
                            Hello, {get_user_name(@current_scope.account.user_id)}
                          </h1>
                        </div>
                        <dl class="mt-6 flex flex-col sm:mt-1 sm:ml-3 sm:flex-row sm:flex-wrap">
                          <dt class="sr-only">Company</dt>
                          <dd class="flex items-center text-sm font-medium text-gray-500 capitalize sm:mr-6">
                            <.icon
                              name="hero-building-office"
                              class="mr-1.5 size-5 shrink-0 text-gray-400"
                            />
                            {@dashboard_data.user.company}
                          </dd>
                          <dt class="sr-only">Account status</dt>
                          <dd class="mt-3 flex items-center text-sm font-medium text-gray-500 capitalize sm:mt-0 sm:mr-6">
                            <.icon
                              name="hero-shield-check"
                              class="mr-1.5 size-5 shrink-0 text-green-400"
                            />
                            {@dashboard_data.user.status}
                          </dd>
                        </dl>
                      </div>
                    </div>
                  </div>
                  <div class="mt-6 flex space-x-3 md:mt-0 md:ml-4">
                    <button
                      type="button"
                      class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs ring-1 ring-gray-300 ring-inset hover:bg-gray-50"
                    >
                      New Registration
                    </button>
                    <button
                      type="button"
                      class="inline-flex items-center rounded-md bg-green-700 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-green-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green-600"
                    >
                      Search Title
                    </button>
                  </div>
                </div>
              </div>
            </div>
            
    <!-- Overview cards -->
            <div class="mt-8">
              <div class="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
                <h2 class="text-lg/6 font-medium text-gray-900">Overview</h2>
                <div class="mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
                  <!-- Total Registrations Card -->
                  <div class="overflow-hidden rounded-lg bg-white shadow-sm">
                    <div class="p-5">
                      <div class="flex items-center">
                        <div class="shrink-0">
                          <.icon name="hero-document-text" class="size-6 text-gray-400" />
                        </div>
                        <div class="ml-5 w-0 flex-1">
                          <dl>
                            <dt class="truncate text-sm font-medium text-gray-500">
                              Total Registrations
                            </dt>
                            <dd>
                              <div class="text-lg font-medium text-gray-900">
                                {@dashboard_data.stats.total_registrations}
                              </div>
                            </dd>
                          </dl>
                        </div>
                      </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3">
                      <div class="text-sm">
                        <a href="#" class="font-medium text-green-700 hover:text-green-900">
                          View all
                        </a>
                      </div>
                    </div>
                  </div>
                  
    <!-- Pending Approvals Card -->
                  <div class="overflow-hidden rounded-lg bg-white shadow-sm">
                    <div class="p-5">
                      <div class="flex items-center">
                        <div class="shrink-0">
                          <.icon name="hero-clock" class="size-6 text-gray-400" />
                        </div>
                        <div class="ml-5 w-0 flex-1">
                          <dl>
                            <dt class="truncate text-sm font-medium text-gray-500">
                              Pending Approvals
                            </dt>
                            <dd>
                              <div class="text-lg font-medium text-gray-900">
                                {@dashboard_data.stats.pending_approvals}
                              </div>
                            </dd>
                          </dl>
                        </div>
                      </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3">
                      <div class="text-sm">
                        <a href="#" class="font-medium text-green-700 hover:text-green-900">
                          View all
                        </a>
                      </div>
                    </div>
                  </div>
                  
    <!-- Completed This Month Card -->
                  <div class="overflow-hidden rounded-lg bg-white shadow-sm">
                    <div class="p-5">
                      <div class="flex items-center">
                        <div class="shrink-0">
                          <.icon name="hero-check-circle" class="size-6 text-gray-400" />
                        </div>
                        <div class="ml-5 w-0 flex-1">
                          <dl>
                            <dt class="truncate text-sm font-medium text-gray-500">
                              Completed (This Month)
                            </dt>
                            <dd>
                              <div class="text-lg font-medium text-gray-900">
                                {@dashboard_data.stats.completed_this_month}
                              </div>
                            </dd>
                          </dl>
                        </div>
                      </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3">
                      <div class="text-sm">
                        <a href="#" class="font-medium text-green-700 hover:text-green-900">
                          View all
                        </a>
                      </div>
                    </div>
                  </div>
                  
    <!-- Total Revenue Card -->
                  <div class="overflow-hidden rounded-lg bg-white shadow-sm">
                    <div class="p-5">
                      <div class="flex items-center">
                        <div class="shrink-0">
                          <.icon name="hero-currency-dollar" class="size-6 text-gray-400" />
                        </div>
                        <div class="ml-5 w-0 flex-1">
                          <dl>
                            <dt class="truncate text-sm font-medium text-gray-500">Total Revenue</dt>
                            <dd>
                              <div class="text-lg font-medium text-gray-900">
                                KSh {@dashboard_data.stats.total_revenue}
                              </div>
                            </dd>
                          </dl>
                        </div>
                      </div>
                    </div>
                    <div class="bg-gray-50 px-5 py-3">
                      <div class="text-sm">
                        <a href="#" class="font-medium text-green-700 hover:text-green-900">
                          View all
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              
    <!-- Recent Activity -->
              <h2 class="mx-auto mt-8 max-w-6xl px-4 text-lg/6 font-medium text-gray-900 sm:px-6 lg:px-8">
                Recent Activity
              </h2>
              
    <!-- Activity table -->
              <div class="mt-2">
                <div class="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
                  <div class="mt-2 flex flex-col">
                    <div class="min-w-full overflow-hidden overflow-x-auto align-middle shadow-sm sm:rounded-lg">
                      <table class="min-w-full divide-y divide-gray-200">
                        <thead>
                          <tr>
                            <th
                              scope="col"
                              class="bg-gray-50 px-6 py-3 text-left text-sm font-semibold text-gray-900"
                            >
                              Transaction
                            </th>
                            <th
                              scope="col"
                              class="bg-gray-50 px-6 py-3 text-right text-sm font-semibold text-gray-900"
                            >
                              Amount
                            </th>
                            <th
                              scope="col"
                              class="hidden bg-gray-50 px-6 py-3 text-left text-sm font-semibold text-gray-900 md:block"
                            >
                              Status
                            </th>
                            <th
                              scope="col"
                              class="bg-gray-50 px-6 py-3 text-right text-sm font-semibold text-gray-900"
                            >
                              Date
                            </th>
                          </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200 bg-white">
                          <tr :for={activity <- @dashboard_data.recent_activities} class="bg-white">
                            <td class="w-full max-w-0 px-6 py-4 text-sm whitespace-nowrap text-gray-900">
                              <div class="flex">
                                <a href="#" class="group inline-flex space-x-2 truncate text-sm">
                                  <.icon
                                    name="hero-document-text"
                                    class="size-5 shrink-0 text-gray-400 group-hover:text-gray-500"
                                  />
                                  <p class="truncate text-gray-500 group-hover:text-gray-900">
                                    {activity.title}
                                  </p>
                                </a>
                              </div>
                            </td>
                            <td class="px-6 py-4 text-right text-sm whitespace-nowrap text-gray-500">
                              <span class="font-medium text-gray-900">KSh {activity.amount}</span>
                            </td>
                            <td class="hidden px-6 py-4 text-sm whitespace-nowrap text-gray-500 md:block">
                              <span class={[
                                "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium capitalize",
                                case activity.status do
                                  "completed" -> "bg-green-100 text-green-800"
                                  "pending" -> "bg-yellow-100 text-yellow-800"
                                  "processing" -> "bg-blue-100 text-blue-800"
                                  "failed" -> "bg-red-100 text-red-800"
                                  _ -> "bg-gray-100 text-gray-800"
                                end
                              ]}>
                                {activity.status}
                              </span>
                            </td>
                            <td class="px-6 py-4 text-right text-sm whitespace-nowrap text-gray-500">
                              <time datetime={activity.date}>{activity.date}</time>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </main>
        </div>
      </div>
    </Layouts.dashboard>
    """
  end

  defp get_user_name(user_id) do
    user = Accounts.get_user(user_id)
    "#{user.first_name} #{user.surname}"
  end
end
