defmodule EcampusWeb.SpecialityLive.Show do
  @moduledoc """
  LiveView for displaying details of a specific academic speciality.

  Supports rendering a speciality in either view or edit mode,
  depending on the current live action.
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Specialities

  @impl true
  @spec mount(map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), any(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_params(%{"id" => id} = params, _uri, socket) do
    return_to = Map.get(params, "return_to", "/admin/specialities")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:speciality, Specialities.get_speciality!(id))
     |> assign(:return_to, return_to)}
  end

  @spec page_title(:show | :edit) :: String.t()
  defp page_title(:show), do: dgettext("specialities", "Show")
  defp page_title(:edit), do: dgettext("specialities", "Edit")
end
