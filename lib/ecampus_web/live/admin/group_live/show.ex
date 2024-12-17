defmodule EcampusWeb.GroupLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Groups
  alias Ecampus.Specialities

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:group, Groups.get_group!(id))
     |> assign(:specialities, Specialities.list_specialities())}
  end

  defp page_title(:show), do: "Show Group"
  defp page_title(:edit), do: "Edit Group"
end
