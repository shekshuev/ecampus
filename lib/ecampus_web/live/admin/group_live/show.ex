defmodule EcampusWeb.GroupLive.Show do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Groups

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "speciality_id" => speciality_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:group, Groups.get_group!(id))
     |> assign(:speciality_id, speciality_id)}
  end

  defp page_title(:show), do: dgettext("groups", "Show Group")
  defp page_title(:edit), do: dgettext("groups", "Edit Group")
end
