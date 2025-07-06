defmodule EcampusWeb.SubjectLive.Show do
  @moduledoc """
  LiveView for displaying details of a specific academic subject.

  Supports rendering a subject in either view or edit mode, depending
  on the current live action.
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Subjects

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
    return_to = Map.get(params, "return_to", ~p"/admin/subjects")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:subject, Subjects.get_subject!(id))
     |> assign(:return_to, return_to)}
  end

  @spec page_title(:show | :edit) :: String.t()
  defp page_title(:show), do: dgettext("subjects", "Show")
  defp page_title(:edit), do: dgettext("subjects", "Edit")
end
