defmodule ETitleWeb.AccountLive.Registration do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Register for an account
            <:subtitle>
              Already registered?
              <.link navigate={~p"/accounts/log-in"} class="font-semibold text-brand hover:underline">
                Log in
              </.link>
              to your account now.
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.input
            field={@form[:first_name]}
            type="text"
            label="First Name"
            autocomplete="first_name"
            required
          />
          <.input
            field={@form[:middle_name]}
            type="text"
            label="Middle Name"
            autocomplete="middle_name"
          />
          <.input
            field={@form[:surname]}
            type="text"
            label="Surname"
            autocomplete="surname"
            required
          />
          <.inputs_for :let={account_form} field={@form[:accounts]}>
            <.input
              field={account_form[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              required
            />

            <.input
              field={account_form[:phone_number]}
              type="tel"
              label="Phone Number"
              placeholder="254XXXXXXXXX"
              autocomplete="tel"
              required
            />
          </.inputs_for>
          <.input
            field={@form[:identity_doc_no]}
            type="text"
            label="Identity Document Number"
            placeholder="XXXXXXXXX"
            autocomplete="tel"
            required
          />
          <.button phx-disable-with="Creating account..." class="btn btn-primary w-full mt-4">
            Create an account
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{account: account}}} = socket)
      when not is_nil(account) do
    {:ok, redirect(socket, to: ETitleWeb.AccountAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_and_account()

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"account" => account_params}, socket) do
    case Accounts.register_account(account_params) do
      {:ok, user} ->
        account = user.accounts |> List.first()
        role = Accounts.get_role_by_name("user")

        {:ok, _} =
          Accounts.deliver_login_instructions(
            account,
            &url(~p"/accounts/log-in/#{&1}")
          )

        Accounts.create_account_role(%{
          account_id: account.id,
          role_id: role.id
        })

        {:noreply,
         socket
         |> put_flash(
           :info,
           "An email was sent to #{account.email}, please access it to confirm your account."
         )
         |> push_navigate(to: ~p"/accounts/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset = Accounts.change_user_and_account(account_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "account")
    assign(socket, form: form)
  end
end
