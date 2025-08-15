defmodule ETitleWeb.UserLive.Login do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-3xl mx-auto py-12 px-6">
        <div class="bg-white rounded-xl shadow-lg p-8 border-t-4 border-green-700">
          <div class="text-center">
            <.header>
              <h2 class="text-2xl font-bold text-green-700 text-center mb-2">Log in</h2>
              <:subtitle>
                <%= if @current_scope do %>
                  You need to reauthenticate to perform sensitive actions on your account.
                <% else %>
                  Don't have an account? <.link
                    navigate={~p"/users/register"}
                    class="text-green-700 font-medium hover:underline"
                    phx-no-format
                  >Sign up</.link> for an account now.
                <% end %>
              </:subtitle>
            </.header>
          </div>

          <div :if={local_mail_adapter?()} class="alert alert-info">
            <.icon name="hero-information-circle" class="size-6 shrink-0" />
            <div>
              <p>You are running the local mail adapter.</p>
              <p>
                To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
              </p>
            </div>
          </div>

          <.form
            :let={f}
            for={@form}
            id="login_form_magic"
            action={~p"/users/log-in"}
            phx-submit="submit_magic"
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              required
              phx-mounted={JS.focus()}
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.button class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded shadow">
              Log in with email <span aria-hidden="true">→</span>
            </.button>
          </.form>

          <div class="divider">or</div>

          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              required
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              autocomplete="current-password"
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.button
              class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded shadow"
              name={@form[:remember_me].name}
              value="true"
            >
              Log in and stay logged in <span aria-hidden="true">→</span>
            </.button>
            <.button class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded shadow mt-2">
              Log in only this time
            </.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:e_title, ETitle.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
