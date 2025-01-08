defmodule EcampusWeb.LessonTopicLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Lessons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "lesson_id" => lesson_id}, _, socket) do
    lesson_topic =
      id |> Lessons.get_lesson_topic() |> parse_markdown()

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson_id, lesson_id)
     |> assign(:lesson_topic, lesson_topic)}
  end

  defp parse_markdown(lesson_topic) do
    html_content =
      lesson_topic.content
      |> Earmark.as_html!()
      |> Phoenix.HTML.raw()

    lesson_topic |> Map.put("html_content", html_content)
  end

  defp page_title(:show), do: "Show Lesson topic"
  defp page_title(:edit), do: "Edit Lesson topic"

  @impl true
  def handle_event("reload", _params, socket) do
    lesson_topic =
      socket.assigns.lesson_topic.id
      |> Lessons.get_lesson_topic()
      |> parse_markdown()

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson_id, socket.assigns.lesson_id)
     |> assign(:lesson_topic, lesson_topic)}
  end
end
