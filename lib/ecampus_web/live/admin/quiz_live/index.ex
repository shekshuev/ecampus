defmodule EcampusWeb.QuizLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Quiz

  @impl true
  def mount(%{"lesson_id" => lesson_id} = params, _session, socket) do
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 10)

    {:ok, %{list: quizzes, pagination: pagination}} =
      Quizzes.list_quizzes(%{"page" => page, "page_size" => page_size})

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:lesson_id, String.to_integer(lesson_id))
     |> assign(:current_page, page)
     |> assign(:quizzes, quizzes |> Enum.map(fn q -> {"quizzes-#{q.id}", q} end))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"page" => page, "page_size" => page_size} = params) do
    page = String.to_integer(page || "1")
    page_size = String.to_integer(page_size || "10")

    {:ok, %{list: quizzes, pagination: pagination}} =
      Quizzes.list_quizzes(%{"page" => page, "page_size" => page_size})

    socket
    |> assign(:page_title, "Listing Quizzes")
    |> assign(:pagination, pagination)
    |> assign(:current_page, page)
    |> assign(:params, params)
    |> assign(:quizzes, quizzes |> Enum.map(fn q -> {"quizzes-#{q.id}", q} end))
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
  def handle_info({EcampusWeb.QuizLive.FormComponent, {:saved, _}}, socket) do
    %{page_size: page_size, page: page} = Map.get(socket.assigns, :pagination)

    {:ok, %{list: quizzes, pagination: pagination}} =
      Quizzes.list_quizzes(%{"page" => page, "page_size" => page_size})

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:current_page, page)
     |> assign(:quizzes, quizzes |> Enum.map(fn q -> {"quizzes-#{q.id}", q} end))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quiz = Quizzes.get_quiz(id)
    {:ok, _} = Quizzes.delete_quiz(quiz)

    %{page_size: page_size, page: page} = Map.get(socket.assigns, :pagination)

    {:ok, %{list: quizzes, pagination: pagination}} =
      Quizzes.list_quizzes(%{"page" => page, "page_size" => page_size})

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:current_page, page)
     |> assign(:quizzes, quizzes |> Enum.map(fn q -> {"quizzes-#{q.id}", q} end))}
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
