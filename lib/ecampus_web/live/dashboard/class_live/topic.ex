defmodule EcampusWeb.Dashboard.ClassLive.Topic do
  use EcampusWeb, :live_view
  alias Ecampus.Classes
  alias Ecampus.Lessons
  alias EcampusWeb.MdRenderer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "class_id" => class_id}, _, socket) do
    topic = Lessons.get_lesson_topic(id) |> MdRenderer.parse_markdown()

    class = Classes.get_class(class_id)
    %{lesson_id: lesson_id} = class

    %{group_id: group_id} = socket.assigns[:current_user]

    case {class, topic} do
      {%{group: %{id: ^group_id}}, %{lesson_id: ^lesson_id}} ->
        {:noreply,
         socket
         |> assign(:topic, topic)}

      {_, _} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/dashboard")}
    end
  end
end
