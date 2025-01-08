defmodule EcampusWeb.Dashboard.ClassLive.Index do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Classes
  alias Ecampus.Lessons

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    class = Classes.get_class(id)

    lesson_topics = Lessons.list_lesson_topics(%{"lesson_id" => class.lesson_id})

    %{group_id: group_id} = socket.assigns[:current_user]

    case class do
      %{group: %{id: ^group_id}} ->
        {:noreply,
         socket
         |> assign(:class, class)
         |> assign(:lesson_topics, lesson_topics)}

      _ ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/dashboard")}
    end
  end
end
