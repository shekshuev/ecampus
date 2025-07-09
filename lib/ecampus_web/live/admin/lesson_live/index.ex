defmodule EcampusWeb.LessonLive.Index do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Lessons
  alias Ecampus.Lessons.Lesson

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"subject_id" => subject_id} = params, url, socket) do
    parsed = URI.parse(url)
    full_path = parsed.path <> if(parsed.query, do: "?" <> parsed.query, else: "")

    {:noreply,
     socket
     |> assign(:subject_id, subject_id)
     |> allow_upload(:lesson_json, accept: ~w(.json), max_entries: 1, auto_upload?: true)
     |> apply_action(socket.assigns.live_action, params, full_path)}
  end

  defp apply_action(socket, :edit, %{"id" => id}, _full_path) do
    socket
    |> assign(:page_title, dgettext("lessons", "Edit Lesson"))
    |> assign(:lesson, Lessons.get_lesson!(id))
  end

  defp apply_action(socket, :new, _params, _full_path) do
    socket
    |> assign(:page_title, dgettext("lessons", "New Lesson"))
    |> assign(:lesson, %Lesson{})
  end

  defp apply_action(socket, :index, %{"subject_id" => subject_id} = params, full_path) do
    filters =
      [%{"field" => "subject_id", "op" => "==", "value" => subject_id}] ++
        Map.get(params, "filters", [])

    params = Map.put(params, "filters", filters)

    {lessons, meta} = Lessons.list_lessons(params)

    socket
    |> assign(:meta, meta)
    |> assign(:current_path, full_path)
    |> stream(:lessons, lessons, reset: true)
    |> assign(:page_title, dgettext("lessons", "Listing Lessons"))
    |> assign(:lesson, nil)
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
