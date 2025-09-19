defmodule ETitleWeb.Admin.AccountLive.Form do
  use ETitleWeb, :live_view

  alias ETitle.Accounts.Schemas.Account
  alias ETitle.Accounts
  alias ETitle.Accounts.Schemas.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage account records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="account-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:phone_number]} type="text" label="Phone number" />
        <.input field={@form[:email]} type="text" label="Email" />

        <.input
          field={@form[:user_id_no]}
          type="text"
          label="User Identity Document"
          placeholder="Enter user identity document number to link user"
          required
        />
        <%= if @user do %>
          <.input
            field={@form[:user_name]}
            type="text"
            label="User Name"
            value={"#{@user.first_name} #{@user.middle_name} #{@user.surname}"}
            readonly
          />
        <% end %>
        <.input
          field={@form[:type]}
          type="text"
          value="staff"
          hidden
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Account</.button>
          <.button navigate={~p"/admin/accounts"}>Cancel</.button>
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
     |> assign(:user, nil)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    account = %Account{}

    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, account)
    |> assign(:form, to_form(Accounts.change_account_email(account)))
  end

  @impl true
  def handle_event("validate", %{"account" => account_params}, socket) do
    {account_params, user} = normalize_account_params(account_params, socket.assigns.account)

    changeset =
      socket.assigns.account
      |> Accounts.change_account_email(account_params)
      |> add_user_document_number_errors(account_params["user_id_no"], user)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    {account_params, _user} = normalize_account_params(account_params, socket.assigns.account)

    save_account(socket, socket.assigns.live_action, account_params)
  end

  defp normalize_account_params(account_params, _account) do
    user_id_no = Map.get(account_params, "user_id_no", "")
    user = Accounts.get_user_by_identity_document(user_id_no)
    {add_user_id_to_params(user, account_params), user}
  end

  defp save_account(socket, :new, account_params) do
    case Accounts.create_account(account_params) do
      {:ok, account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, account))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_, _account), do: ~p"/admin/accounts"

  defp add_user_id_to_params(user, params) do
    if user do
      Map.put(params, "user_id", user.id)
    else
      params
    end
  end

  defp add_user_document_number_errors(changeset, "", _user) do
    Ecto.Changeset.add_error(changeset, :user_id_no, "can't be blank")
  end

  defp add_user_document_number_errors(changeset, _user_id_no, %User{} = _user), do: changeset

  defp add_user_document_number_errors(changeset, _user_id_no, nil) do
    Ecto.Changeset.add_error(changeset, :user_id_no, "No user with this identity document number")
  end
end
