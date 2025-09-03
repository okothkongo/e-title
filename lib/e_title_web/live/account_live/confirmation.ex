defmodule ETitleWeb.AccountLive.Confirmation do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>Welcome {@account.email}</.header>
        </div>

        <.form
          :if={!@account.confirmed_at}
          for={@form}
          id="confirmation_form"
          phx-mounted={JS.focus_first()}
          phx-submit="submit"
          action={~p"/accounts/log-in?_action=confirmed"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.button
            name={@form[:remember_me].name}
            value="true"
            phx-disable-with="Confirming..."
            variant="primary"
            class="w-full"
          >
            Confirm and stay logged in
          </.button>
          <.button phx-disable-with="Confirming..." variant="secondary" class="w-full mt-2">
            Confirm and log in only this time
          </.button>
        </.form>

        <.form
          :if={@account.confirmed_at}
          for={@form}
          id="login_form"
          phx-submit="submit"
          phx-mounted={JS.focus_first()}
          action={~p"/accounts/log-in"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <%= if @current_scope do %>
            <.button phx-disable-with="Logging in..." variant="primary" class="w-full">
              Log in
            </.button>
          <% else %>
            <.button
              name={@form[:remember_me].name}
              value="true"
              phx-disable-with="Logging in..."
              variant="primary"
              class="w-full"
            >
              Keep me logged in on this device
            </.button>
            <.button phx-disable-with="Logging in..." variant="secondary" class="w-full mt-2">
              Log me in only this time
            </.button>
          <% end %>
        </.form>

        <p :if={!@account.confirmed_at} class="alert alert-outline mt-8">
          Tip: If you prefer passwords, you can enable them in the account settings.
        </p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if account = Accounts.get_account_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "account")

      {:ok, assign(socket, account: account, form: form, trigger_submit: false),
       temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "Magic link is invalid or it has expired.")
       |> push_navigate(to: ~p"/accounts/log-in")}
    end
  end

  @impl true
  def handle_event("submit", %{"account" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "account"), trigger_submit: true)}
  end
end
