defmodule ETitleWeb.UserLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Accounts
  alias ETitle.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="user-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:middle_name]} type="text" label="Middle name" />
        <.input field={@form[:surname]} type="text" label="Surname" />
        <.input field={@form[:identity_document]} type="text" label="Identity document" />
        <.inputs_for :let={account_form} field={@form[:accounts]}>
          <.input field={account_form[:email]} type="email" label="Email" />
          <.input field={account_form[:phone_number]} type="text" label="Phone number" />
        </.inputs_for>
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save User</.button>
          <%!-- <.button navigate={return_path(@current_scope, @return_to, @user)}>Cancel</.button> --%>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_user!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(socket.assigns.current_scope, user)))
  end

  defp apply_action(socket, :new, _params) do
    # user = %User{id: socket.assigns.current_scope.account.user_id}

    socket
    |> assign(:page_title, "New User")
    # |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user_and_account()))
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_and_account(user_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.live_action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.current_scope, socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, user)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user_and_account(user_params) do
      {:ok, user} ->
        send_login_instructions(user)

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp send_login_instructions(%User{accounts: [account]}) do
    {:ok, _} =
      Accounts.deliver_login_instructions(
        account,
        &url(~p"/accounts/log-in/#{&1}")
      )
  end

  defp return_path("index", _user), do: ~p"/accounts/log-in"
  defp return_path(_scope, "index", _user), do: ~p"/users"
  defp return_path(_scope, "show", user), do: ~p"/users/#{user}"
end
