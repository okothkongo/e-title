defmodule ETitleWeb.IdentityLive.Index do
  use ETitleWeb, :live_view

  alias ETitle.Accounts
  alias ETitle.Accounts.Identity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :identities, Accounts.list_identities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Identity")
    |> assign(:identity, Accounts.get_identity!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Identity")
    |> assign(:identity, %Identity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Identities")
    |> assign(:identity, nil)
  end

  @impl true
  def handle_info({ETitleWeb.IdentityLive.FormComponent, {:saved, identity}}, socket) do
    {:noreply, stream_insert(socket, :identities, identity)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    identity = Accounts.get_identity!(id)
    {:ok, _} = Accounts.delete_identity(identity)

    {:noreply, stream_delete(socket, :identities, identity)}
  end
end
