defmodule EcampusWeb.LessonLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Lessons
  alias Ecampus.Lessons.Lesson
  alias Ecampus.Subjects

  @impl true
  def mount(_params, _session, socket) do
    subjects = Subjects.list_subjects()

    {:ok,
     socket
     |> assign(:subjects, subjects)
     |> stream(:lessons, Lessons.list_lessons())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lesson")
    |> assign(:lesson, Lessons.get_lesson!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lesson")
    |> assign(:lesson, %Lesson{})
    |> assign(:subjects, Subjects.list_subjects())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lessons")
    |> assign(:lesson, nil)
    |> assign(:subjects, Subjects.list_subjects())
  end

  @impl true
  def handle_info({EcampusWeb.LessonLive.FormComponent, {:saved, lesson}}, socket) do
    {:noreply, stream_insert(socket, :lessons, lesson)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Lessons.get_lesson!(id)
    {:ok, _} = Lessons.delete_lesson(lesson)

    {:noreply, stream_delete(socket, :lessons, lesson)}
  end
end
