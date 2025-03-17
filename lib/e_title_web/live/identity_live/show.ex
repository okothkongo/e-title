defmodule ETitleWeb.IdentityLive.Show do
  use ETitleWeb, :live_view

  alias ETitle.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:identity, Accounts.get_identity!(id))}
  end

  defp page_title(:show), do: "Show Identity"
  defp page_title(:edit), do: "Edit Identity"
end
