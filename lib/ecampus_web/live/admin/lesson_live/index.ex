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

  defp apply_action(socket, :index, params, full_path) do
    {lessons, meta} = Lessons.list_lessons(params)

    socket
    |> assign(:meta, meta)
    |> assign(:current_path, full_path)
    |> stream(:lessons, lessons, reset: true)
    |> assign(:page_title, dgettext("lesson", "Listing Lessons"))
    |> assign(:lesson, nil)
  end

  @impl true
  def handle_info({EcampusWeb.LessonLive.FormComponent, {:saved, lesson}}, socket) do
    {:noreply, stream_insert(socket, :lessons, lesson)}
  end
end
