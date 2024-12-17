defmodule EcampusWeb.LessonTopicLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Lessons
  alias Ecampus.Lessons.LessonTopic

  @impl true
  def mount(%{"lesson_id" => lesson_id}, _session, socket) do
    {:ok, %{list: lesson_topics, pagination: pagination}} =
      Lessons.list_lesson_topics(%{"lesson_id" => String.to_integer(lesson_id)})

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:lesson_id, String.to_integer(lesson_id))
     |> stream(:lesson_topics, lesson_topics)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lesson topic")
    |> assign(:lesson_topic, Lessons.get_lesson_topic(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lesson topic")
    |> assign(:lesson_topic, %LessonTopic{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lesson topics")
    |> assign(:lesson_topic, nil)
  end

  @impl true
  def handle_info({EcampusWeb.LessonTopicLive.FormComponent, {:saved, lesson_topic}}, socket) do
    {:noreply, stream_insert(socket, :lesson_topics, lesson_topic)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson_topic = Lessons.get_lesson_topic(id)
    {:ok, _} = Lessons.delete_lesson_topic(lesson_topic)

    {:noreply, stream_delete(socket, :lesson_topics, lesson_topic)}
  end
end
