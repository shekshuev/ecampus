defmodule EcampusWeb.Dashboard.ClassLive.Index do
  use EcampusWeb, :live_view
  alias Ecampus.Classes
  alias Ecampus.Lessons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    class = Classes.get_class(id)

    {:ok, %{list: lesson_topics, pagination: pagination}} =
      Lessons.list_lesson_topics(%{"lesson_id" => class.lesson_id})

    %{group_id: group_id} = socket.assigns[:current_user]

    case class do
      %{group: %{id: ^group_id}} ->
        {:noreply,
         socket
         |> assign(:class, class)
         |> assign(:lesson_topics, lesson_topics)
         |> assign(:pagination, pagination)}

      _ ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/dashboard")}
    end
  end
end
