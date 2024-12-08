defmodule EcampusWeb.LessonLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Lessons
  alias Ecampus.Subjects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson, Lessons.get_lesson!(id))
     |> assign(:subjects, Subjects.list_subjects())}
  end

  defp page_title(:show), do: "Show Lesson"
  defp page_title(:edit), do: "Edit Lesson"
end
