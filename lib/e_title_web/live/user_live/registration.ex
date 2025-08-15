defmodule ETitleWeb.UserLive.Registration do
  use ETitleWeb, :live_view

  alias ETitle.Accounts
  alias ETitle.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-3xl mx-auto py-12 px-6">
        <div class="bg-white rounded-xl shadow-lg p-8 border-t-4 border-green-700">
          <div class="text-center">
            <.header>
              <h2 class="text-2xl font-bold text-green-700 text-center mb-2">
                Register for an account
              </h2>
              <:subtitle>
                Already registered?
                <.link navigate={~p"/users/log-in"} class="text-green-700 font-medium hover:underline">
                  Log in
                </.link>
                to your account now.
              </:subtitle>
            </.header>
          </div>

          <.form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            class="space-y-5"
          >
            <.input
              field={@form[:first_name]}
              type="text"
              label="First Name"
              required
              phx-mounted={JS.focus()}
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:middle_name]}
              type="text"
              label="Middle Name"
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:surname]}
              type="text"
              label="Surname"
              required
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              required
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:phone_number]}
              type="text"
              label="Phone Number"
              required
              placeholder="254XXXXXXXXX"
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:national_id]}
              type="text"
              label="National ID"
              required
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.input
              field={@form[:role]}
              type="hidden"
              value="user"
              required
              class="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <.button
              phx-disable-with="Creating account..."
              class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded shadow"
            >
              Create an account
            </.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: ETitleWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = User.email_changeset(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "An email was sent to #{user.email}, please access it to confirm your account."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = User.email_changeset(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
