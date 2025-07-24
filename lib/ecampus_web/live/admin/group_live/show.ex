defmodule EcampusWeb.GroupLive.Show do
  @moduledoc """
  LiveView for displaying and editing a single academic group.

  Loads the group by ID and shows it in either show or edit mode,
  based on the `live_action`. Also sets the related `speciality_id`.
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Groups
  alias Phoenix.LiveView.Socket

  @impl true
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), any(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_params(%{"id" => id, "speciality_id" => speciality_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:group, Groups.get_group!(id))
     |> assign(:speciality_id, speciality_id)}
  end

  @spec page_title(:show | :edit) :: String.t()
  defp page_title(:show), do: dgettext("groups", "Show")
  defp page_title(:edit), do: dgettext("groups", "Edit")
end
