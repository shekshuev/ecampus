defmodule EcampusWeb.LessonTopicLive.Index do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Lessons
  alias Ecampus.Lessons.LessonTopic
  alias Phoenix.LiveView.Socket

  @impl true
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), String.t(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_params(%{"lesson_id" => lesson_id} = params, url, socket) do
    parsed = URI.parse(url)
    full_path = parsed.path <> if(parsed.query, do: "?" <> parsed.query, else: "")

    params = Map.update(params, "page_size", "10", fn existing -> existing end)

    {:noreply,
     socket
     |> assign(:lesson_id, lesson_id)
     |> apply_action(socket.assigns.live_action, params, full_path)}
  end

  @spec apply_action(Socket.t(), :index | :edit | :new, map(), String.t()) :: Socket.t()
  defp apply_action(socket, :edit, %{"id" => id}, _full_path) do
    socket
    |> assign(:page_title, dgettext("lesson_topics", "Edit"))
    |> assign(:lesson_topic, Lessons.get_lesson_topic(id))
  end

  defp apply_action(socket, :new, _params, _full_path) do
    socket
    |> assign(:page_title, dgettext("lesson_topics", "New"))
    |> assign(:lesson_topic, %LessonTopic{})
  end

  defp apply_action(socket, :index, params, full_path) do
    {lesson_topics, meta} = Lessons.list_lessons_topics(params)

    socket
    |> assign(:meta, meta)
    |> assign(:current_path, full_path)
    |> stream(:lesson_topics, lesson_topics, reset: true)
    |> assign(:page_title, dgettext("lesson_topics", "Listing Lesson Topics"))
    |> assign(:lesson_topic, nil)
  end

  @impl true
  @spec handle_info({module(), {:saved, LessonTopic.t()}}, Socket.t()) :: {:noreply, Socket.t()}
  def handle_info({EcampusWeb.LessonLive.FormComponent, {:saved, lesson_topic}}, socket) do
    {:noreply, stream_insert(socket, :lesson_topics, lesson_topic)}
  end
end
