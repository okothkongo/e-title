defmodule ETitleWeb.IdentityLive.FormComponent do
  use ETitleWeb, :live_component
  require Logger
  alias ETitle.Accounts
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage identity records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="identity-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:other_names]} type="text" label="Other names" />
        <.input field={@form[:surname]} type="text" label="Surname" />
        <.input field={@form[:birth_date]} type="date" label="Birth date" />
        <.input field={@form[:id_doc]} type="text" label="Id doc" />
        <.input
          field={@form[:nationality]}
          type="select"
          label="Nationality"
          options={Ecto.Enum.values(ETitle.Accounts.Schemas.Identity, :nationality)}
          prompt=""
        />
        <.input field={@form[:kra_pin]} type="text" label="Kra pin" />
        <.input field={@form[:passport_photo]} type="text" label="Passport photo" />
        <%= if @action == :new do %>
          <.inputs_for :let={f} field={@form[:accounts]}>
            <.input field={f[:email]} type="email" label="Email Address" />
            <.input field={f[:password]} type="hidden" value={get_password()} />
          </.inputs_for>
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save Identity</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{identity: identity, action: :edit} = assigns, socket) do
    changeset =
      identity
      |> Accounts.change_identity()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  def update(%{identity: identity} = assigns, socket) do
    changeset =
      identity
      |> Accounts.change_identity()
      |> Ecto.Changeset.put_assoc(:accounts, [%{}])

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"identity" => identity_params}, socket) do
    changeset =
      socket.assigns.identity
      |> Accounts.change_identity(identity_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"identity" => identity_params}, socket) do
    password = identity_params["accounts"][0]["password"]
    Logger.info("This is the default password: #{inspect(password)}")
    save_identity(socket, socket.assigns.action, identity_params)
  end

  defp save_identity(socket, :edit, identity_params) do
    case Accounts.update_identity(socket.assigns.identity, identity_params) do
      {:ok, identity} ->
        notify_parent({:saved, identity})

        {:noreply,
         socket
         |> put_flash(:info, "Identity updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_identity(socket, :new, identity_params) do
    case Accounts.create_identity(identity_params) do
      {:ok, identity} ->
        notify_parent({:saved, identity})

        {:noreply,
         socket
         |> put_flash(:info, "Identity created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp get_password, do: :crypto.strong_rand_bytes(13) |> Base.url_encode64(padding: false)
end
