defmodule EcampusWeb.LessonLive.Show do
  @moduledoc """
  LiveView for displaying and editing a single lesson.

  Loads the lesson by ID and renders it in either show or edit mode.
  Sets the locale, handles route parameters, and manages navigation state.
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Lessons
  alias Phoenix.LiveView.Socket

  @impl true
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), any(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_params(%{"id" => id, "subject_id" => subject_id} = params, _, socket) do
    return_to = Map.get(params, "return_to", "/admin/subjects")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson, Lessons.get_lesson!(id))
     |> assign(:subject_id, subject_id)
     |> assign(:return_to, return_to)}
  end

  @spec page_title(:show | :edit) :: String.t()
  defp page_title(:show), do: dgettext("lessons", "Show")
  defp page_title(:edit), do: dgettext("lessons", "Edit")
end
