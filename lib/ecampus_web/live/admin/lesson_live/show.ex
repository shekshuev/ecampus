defmodule EcampusWeb.LessonLive.Show do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Lessons

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "subject_id" => subject_id} = params, _, socket) do
    return_to = Map.get(params, "return_to", "/admin/subjects")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson, Lessons.get_lesson!(id))
     |> assign(:subject_id, subject_id)
     |> assign(:return_to, return_to)}
  end

  defp page_title(:show), do: dgettext("lessons", "Show Lesson")
  defp page_title(:edit), do: dgettext("lessons", "Edit Lesson")
end
