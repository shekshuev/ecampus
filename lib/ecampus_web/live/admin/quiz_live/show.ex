defmodule EcampusWeb.QuizLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "lesson_id" => lesson_id}, _, socket) do
    quiz = Quizzes.get_quiz(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson_id, lesson_id)
     |> assign(:quiz, quiz)}
  end

  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
end
