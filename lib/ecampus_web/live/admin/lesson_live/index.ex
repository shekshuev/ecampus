defmodule EcampusWeb.LessonLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Lessons
  alias Ecampus.Lessons.Lesson
  alias Ecampus.Subjects

  @impl true
  def mount(%{"subject_id" => subject_id}, _session, socket) do
    subjects = Subjects.list_subjects()

    {:ok,
     socket
     |> assign(:subjects, subjects)
     |> assign(:subject_id, subject_id)
     |> allow_upload(:lesson_json, accept: ~w(.json), max_entries: 1, auto_upload?: true)
     |> stream(:lessons, Lessons.list_lessons(%{"subject_id" => subject_id}))}
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

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :lesson_json, fn %{path: path}, _entry ->
        case File.read(path) do
          {:ok, content} ->
            {:ok, content}

          {:error, reason} ->
            {:error, "Failed to read file: #{inspect(reason)}"}
        end
      end)

    %{id: subject_id} = Enum.at(socket.assigns.subjects, 0)

    for content <- uploaded_files do
      Lessons.import_lesson(content, subject_id)
    end

    {:noreply,
     socket
     |> put_flash(:info, "Lesson uploaded successfully")
     |> stream(:lessons, Lessons.list_lessons())}
  end
end
