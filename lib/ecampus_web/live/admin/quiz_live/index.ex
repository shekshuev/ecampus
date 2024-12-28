defmodule EcampusWeb.QuizLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Quiz

  @impl true
  def mount(%{"lesson_id" => lesson_id}, _session, socket) do
    {:ok, %{list: quizzes, pagination: pagination}} =
      Quizzes.list_quizzes()

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:lesson_id, String.to_integer(lesson_id))
     |> stream(:quizzes, quizzes)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Quiz")
    |> assign(:quiz, Quizzes.get_quiz(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Quiz")
    |> assign(:quiz, %Quiz{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Quizzes")
    |> assign(:quiz, nil)
  end

  @impl true
  def handle_info({EcampusWeb.QuizLive.FormComponent, {:saved, quiz}}, socket) do
    {:noreply, stream_insert(socket, :quizzes, quiz)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quiz = Quizzes.get_quiz(id)
    {:ok, _} = Quizzes.delete_quiz(quiz)

    {:noreply, stream_delete(socket, :quizzes, quiz)}
  end
end
