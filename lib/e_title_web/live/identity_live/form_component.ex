defmodule ETitleWeb.IdentityLive.FormComponent do
  use ETitleWeb, :live_component

  alias ETitle.Accounts

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
        <.input field={@form[:nationality]} type="text" label="Nationality" />
        <.input field={@form[:kra_pin]} type="text" label="Kra pin" />
        <.input field={@form[:passport_photo]} type="text" label="Passport photo" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Identity</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{identity: identity} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_identity(identity))
     end)}
  end

  @impl true
  def handle_event("validate", %{"identity" => identity_params}, socket) do
    changeset = Accounts.change_identity(socket.assigns.identity, identity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"identity" => identity_params}, socket) do
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
end
