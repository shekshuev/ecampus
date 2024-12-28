defmodule EcampusWeb.QuestionLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Answer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case socket.assigns.live_action do
      :show ->
        handle_show(params, socket)

      :edit ->
        handle_edit(params, socket)

      :new_answer ->
        handle_new_answer(params, socket)

      :edit_answer ->
        handle_edit_answer(params, socket)
    end
  end

  defp handle_show(%{"id" => id, "quiz_id" => quiz_id, "lesson_id" => lesson_id}, socket) do
    question = Quizzes.get_question(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(:show))
     |> assign(:quiz_id, quiz_id)
     |> assign(:lesson_id, lesson_id)
     |> assign(:question, question)}
  end

  defp handle_edit(%{"id" => id, "quiz_id" => quiz_id, "lesson_id" => lesson_id}, socket) do
    question = Quizzes.get_question(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(:edit))
     |> assign(:quiz_id, quiz_id)
     |> assign(:lesson_id, lesson_id)
     |> assign(:question, question)}
  end

  defp handle_new_answer(
         %{"question_id" => question_id, "quiz_id" => quiz_id, "lesson_id" => lesson_id},
         socket
       ) do
    question = Quizzes.get_question(question_id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(:new_answer))
     |> assign(:quiz_id, quiz_id)
     |> assign(:lesson_id, lesson_id)
     |> assign(:question, question)
     |> assign(:answer, %Answer{})}
  end

  defp handle_edit_answer(
         %{
           "question_id" => question_id,
           "quiz_id" => quiz_id,
           "lesson_id" => lesson_id,
           "id" => id
         },
         socket
       ) do
    question = Quizzes.get_question(question_id)
    answer = Quizzes.get_answer(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(:edit_answer))
     |> assign(:quiz_id, quiz_id)
     |> assign(:lesson_id, lesson_id)
     |> assign(:question, question)
     |> assign(:answer, answer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    answer = Quizzes.get_answer(id)
    {:ok, _} = Quizzes.delete_answer(answer)

    updated_answers = Enum.reject(socket.assigns.answers, fn a -> a.id == answer.id end)

    {:noreply, assign(socket, :answers, updated_answers)}
  end

  defp page_title(:show), do: "Show Question"
  defp page_title(:edit), do: "Edit Question"
  defp page_title(:edit_answer), do: "Edit Answer"
  defp page_title(:new_answer), do: "New Answer"
end
