defmodule EcampusWeb.QuestionLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Question

  @impl true
  def mount(%{"lesson_id" => lesson_id, "quiz_id" => quiz_id}, _session, socket) do
    {:ok, %{list: questions, pagination: pagination}} =
      Quizzes.list_questions()

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:lesson_id, String.to_integer(lesson_id))
     |> assign(:quiz_id, String.to_integer(quiz_id))
     |> stream(:questions, questions)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Question")
    |> assign(:question, Quizzes.get_question(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Question")
    |> assign(:question, %Question{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Questions")
    |> assign(:question, nil)
  end

  @impl true
  def handle_info({EcampusWeb.QuestionLive.FormComponent, {:saved, question}}, socket) do
    {:noreply, stream_insert(socket, :questions, question)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = Quizzes.get_question(id)
    {:ok, _} = Quizzes.delete_question(question)

    {:noreply, stream_delete(socket, :questions, question)}
  end
end
