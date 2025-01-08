defmodule EcampusWeb.QuestionLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Question

  @impl true
  def mount(%{"lesson_id" => lesson_id, "quiz_id" => quiz_id} = params, _session, socket) do
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 10)

    {:ok, %{list: questions, pagination: pagination}} =
      Quizzes.list_questions(%{
        "quiz_id" => String.to_integer(quiz_id),
        "page" => page,
        "page_size" => page_size
      })

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:lesson_id, String.to_integer(lesson_id))
     |> assign(:quiz_id, String.to_integer(quiz_id))
     |> assign(:current_page, page)
     |> assign(:questions, questions |> Enum.map(fn q -> {"questions-#{q.id}", q} end))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(
         socket,
         :index,
         %{"quiz_id" => quiz_id, "page" => page, "page_size" => page_size} = params
       ) do
    page = String.to_integer(page || "1")
    page_size = String.to_integer(page_size || "10")

    {:ok, %{list: questions, pagination: pagination}} =
      Quizzes.list_questions(%{
        "quiz_id" => String.to_integer(quiz_id),
        "page" => page,
        "page_size" => page_size
      })

    socket
    |> assign(:page_title, "Listing Questions")
    |> assign(:pagination, pagination)
    |> assign(:current_page, page)
    |> assign(:params, params)
    |> assign(:questions, questions |> Enum.map(fn q -> {"questions-#{q.id}", q} end))
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
  def handle_info({EcampusWeb.QuestionLive.FormComponent, {:saved, _}}, socket) do
    %{page: page, page_size: page_size} = Map.get(socket.assigns, :pagination)
    quiz_id = Map.get(socket.assigns, :quiz_id)

    {:ok, %{list: questions, pagination: pagination}} =
      Quizzes.list_questions(%{
        "quiz_id" => quiz_id,
        "page" => page,
        "page_size" => page_size
      })

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:current_page, page)
     |> assign(:questions, questions |> Enum.map(fn q -> {"questions-#{q.id}", q} end))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = Quizzes.get_question(id)
    {:ok, _} = Quizzes.delete_question(question)

    %{page: page, page_size: page_size} = Map.get(socket.assigns, :pagination)
    quiz_id = Map.get(socket.assigns, :quiz_id)

    {:ok, %{list: questions, pagination: pagination}} =
      Quizzes.list_questions(%{
        "quiz_id" => quiz_id,
        "page" => page,
        "page_size" => page_size
      })

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:current_page, page)
     |> assign(:questions, questions |> Enum.map(fn q -> {"questions-#{q.id}", q} end))}
  end

  defp pagination_pages(total_pages, current_page) do
    cond do
      total_pages <= 7 ->
        Enum.to_list(1..total_pages)

      current_page < 4 ->
        [1, 2, 3, 4, :ellipsis, total_pages - 1, total_pages]

      current_page > total_pages - 3 ->
        [1, 2, :ellipsis, total_pages - 3, total_pages - 2, total_pages - 1, total_pages]

      true ->
        [1, :ellipsis, current_page - 1, current_page, current_page + 1, :ellipsis, total_pages]
    end
  end
end
