defmodule EcampusWeb.Dashboard.ClassLive.Topic do
  use EcampusWeb, :live_view
  alias Ecampus.Classes
  alias Ecampus.Lessons
  alias Ecampus.Quizzes

  @stop_rendering_flag "<!-- Rendering stopped -->"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "class_id" => class_id}, _, socket) do
    {topic, socket} =
      Lessons.get_lesson_topic(id)
      |> parse_markdown(socket)

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

  @impl true
  def handle_event("start-quiz", %{"quiz-id" => id}, socket) do
    quiz_id = String.to_integer(id)
    Quizzes.start_quiz(%{quiz_id: quiz_id, user_id: socket.assigns.current_user.id})

    {topic, updated_socket} =
      Map.get(socket.assigns, :topic)
      |> parse_markdown(socket)

    {:noreply,
     updated_socket
     |> assign(:topic, topic)}
  end

  @impl true
  def handle_event(
        "answer-question",
        %{"question-id" => question_id, "question-type" => question_type, "quiz-id" => quiz_id} =
          params,
        socket
      ) do
    answer_ids =
      case question_type do
        "multiple" ->
          params
          |> Enum.filter(fn {key, value} ->
            String.starts_with?(key, "answer-") and value == "true"
          end)
          |> Enum.map(fn {key, _value} ->
            Regex.run(~r/answer-(\d+)/, key)
            |> List.last()
            |> String.to_integer()
          end)

        "sequence" ->
          Map.get(socket.assigns, :sequences, %{}) |> Map.get("#{quiz_id}-#{question_id}", [])

        _ ->
          []
      end

    Quizzes.answer_question(%{
      question_id: question_id,
      user_id: socket.assigns.current_user.id,
      answer: %{answer_ids: answer_ids}
    })

    {topic, socket} =
      Map.get(socket.assigns, :topic)
      |> parse_markdown(socket)

    {:noreply, socket |> assign(:topic, topic)}
  end

  @impl true
  def handle_event(action, %{"quiz-id" => id} = _params, socket)
      when action in ["next-question", "prev-question"] do
    quiz_id = String.to_integer(id)

    question_indexes = Map.get(socket.assigns, :question_indexes, %{})
    quiz = Quizzes.get_started_quiz(%{quiz_id: quiz_id, user_id: socket.assigns.current_user.id})

    current_question_index =
      case Map.get(question_indexes, quiz_id) do
        nil -> 0
        index when index == length(quiz.questions) - 1 and action == "next-question" -> 0
        index when action == "next-question" -> index + 1
        index when index == 0 and action == "prev-question" -> length(quiz.questions) - 1
        index when action == "prev-question" -> index - 1
      end

    updated_socket =
      socket
      |> assign(:question_indexes, Map.put(question_indexes, quiz_id, current_question_index))

    {topic, updated_socket} =
      Map.get(updated_socket.assigns, :topic)
      |> parse_markdown(updated_socket)

    {:noreply,
     updated_socket
     |> assign(:topic, topic)}
  end

  @impl true
  def handle_event(
        action,
        %{"quiz-id" => quiz_id, "question-id" => question_id, "answer-id" => answer_id},
        socket
      )
      when action in ["select-sequence-answer", "unselect-sequence-answer"] do
    sequences = Map.get(socket.assigns, :sequences, %{})

    answers =
      case action do
        "select-sequence-answer" ->
          [String.to_integer(answer_id) | Map.get(sequences, "#{quiz_id}-#{question_id}", [])]

        "unselect-sequence-answer" ->
          Map.get(sequences, "#{quiz_id}-#{question_id}", [])
          |> Enum.filter(fn a -> a != String.to_integer(answer_id) end)
      end

    updated_socket =
      socket
      |> assign(:sequences, Map.put(sequences, "#{quiz_id}-#{question_id}", answers))

    {topic, updated_socket} =
      Map.get(updated_socket.assigns, :topic)
      |> parse_markdown(updated_socket)

    {:noreply,
     updated_socket
     |> assign(:topic, topic)}
  end

  defp render_quiz(assigns) do
    ~H"""
    <div class="not-prose card shadow-md">
      <%= if length(@quiz.questions) == 0 do %>
        <div class="card-body">
          <h2 class="card-title my-0">{@quiz.title}</h2>
          <p class="text-sm">{@quiz.description}</p>
          <div class="card-actions justify-end">
            <button phx-click="start-quiz" phx-value-quiz-id={@quiz.id} class="btn btn-primary">
              Begin
            </button>
          </div>
        </div>
      <% else %>
        <form class="card-body" phx-submit="answer-question">
          <.input name="question-id" type="hidden" value={@question.id} />
          <.input name="quiz-id" type="hidden" value={@quiz.id} />
          <h3 class="card-title my-0">{@question.title}</h3>
          <p class="text-sm">{@question.subtitle}</p>
          <%= if @question.type == :multiple do %>
            <.input name="question-type" type="hidden" value={:multiple} />
            <%= for answer <- @question.answers do %>
              <.input
                name={"answer-#{answer.id}"}
                type="checkbox"
                checked={@has_answer && answer.id in @answered_ids}
                error={@has_answer && answer.id not in @correct_ids}
                success={@has_answer && answer.id in @correct_ids}
                disabled={@has_answer}
                label={answer.title}
              />
              <%= if @has_answer do %>
                <p class={[
                  "text-xs",
                  @has_answer && answer.id not in @correct_ids && "text-error",
                  @has_answer && answer.id in @correct_ids &&
                    "text-success"
                ]}>
                  {answer.subtitle}
                </p>
              <% end %>
            <% end %>
          <% end %>

          <%= if @question.type == :sequence do %>
            <.input name="question-type" type="hidden" value={:sequence} />
            <%= if @has_answer do %>
              <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-start items-center flex-wrap gap-2">
                <%= for answer <- @answered_ids |> Enum.map(fn id -> Enum.find(@question.answers, &(&1.id == id)) end) do %>
                  <button
                    type="button"
                    class={[
                      "btn btn-success btn-sm",
                      @answered_ids == @correct_ids && "btn-success",
                      @answered_ids != @correct_ids && "btn-error"
                    ]}
                  >
                    {answer.title}
                  </button>
                <% end %>
              </div>
              <div class="divider">Right answer</div>
              <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-start items-center flex-wrap gap-2">
                <%= for answer <- @correct_ids |> Enum.map(fn id -> Enum.find(@question.answers, &(&1.id == id)) end) do %>
                  <button type="button" class="btn btn-success btn-sm">
                    {answer.title}
                  </button>
                <% end %>
              </div>
            <% else %>
              <div class="flex w-full flex-col border-opacity-50">
                <%= if length(Map.get(@sequences,"#{@quiz.id}-#{@question.id}", [])) == 0 do %>
                  <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-center items-center ">
                    No items selected
                  </div>
                <% else %>
                  <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-start items-center flex-wrap gap-2">
                    <%= for answer <- Map.get(@sequences,"#{@quiz.id}-#{@question.id}", []) |> Enum.reverse() |> Enum.map(fn id -> Enum.find(@question.answers, &(&1.id == id)) end) do %>
                      <button
                        type="button"
                        phx-click="unselect-sequence-answer"
                        phx-value-quiz-id={@quiz.id}
                        phx-value-question-id={@question.id}
                        phx-value-answer-id={answer.id}
                        class="btn btn-accent btn-sm"
                      >
                        {answer.title}
                        <span class="hero-x-mark"></span>
                      </button>
                    <% end %>
                  </div>
                <% end %>

                <div class="divider">Please select in correct order</div>
                <%= if length(@question.answers) == length(Map.get(@sequences,"#{@quiz.id}-#{@question.id}", [])) do %>
                  <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-center items-center ">
                    No items left
                  </div>
                <% else %>
                  <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-start items-center flex-wrap gap-2">
                    <%= for answer <- @question.answers |> Enum.filter(fn a -> !Enum.member?(Map.get(@sequences,"#{@quiz.id}-#{@question.id}", []), a.id) end) do %>
                      <button
                        type="button"
                        phx-click="select-sequence-answer"
                        phx-value-quiz-id={@quiz.id}
                        phx-value-question-id={@question.id}
                        phx-value-answer-id={answer.id}
                        class="btn btn-neutral btn-sm"
                      >
                        {answer.title}
                      </button>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          <% end %>
          <div class="card-actions justify-end">
            <%= if @question_index > 0 do %>
              <button
                type="button"
                phx-click="prev-question"
                phx-value-quiz-id={@quiz.id}
                class="btn btn-ghost"
              >
                Prev
              </button>
            <% end %>
            <%= if Enum.at(@question.answered_questions, 0).answer == nil do %>
              <button type="submit" class="btn btn-primary">
                Submit
              </button>
            <% else %>
              <%= if @question_index < length(@quiz.questions) - 1 do %>
                <button
                  type="button"
                  phx-click="next-question"
                  phx-value-quiz-id={@quiz.id}
                  class="btn btn-ghost"
                >
                  Next
                </button>
              <% end %>
            <% end %>
          </div>
        </form>
      <% end %>
    </div>
    """
  end

  defp parse_markdown(lesson_topic, socket) do
    {replaced_content, socket} =
      replace_custom_tags(Earmark.as_html!(lesson_topic.content), socket)

    html_content =
      replaced_content
      |> String.split(@stop_rendering_flag)
      |> List.first()

    {Map.put(lesson_topic, :html_content, html_content), socket}
  end

  defp replace_custom_tags(content, socket),
    do:
      content
      |> replace_quiz(socket)

  defp replace_quiz(content, socket) do
    {updated_content, updated_socket} =
      Regex.scan(~r/\[quiz (\d+)\]/, content)
      |> Enum.reduce({content, socket}, fn [_, id], {content_acc, socket_acc} ->
        quiz_id = String.to_integer(id)

        sequences = Map.get(socket.assigns, :sequences, %{})
        question_indexes = Map.get(socket.assigns, :question_indexes, %{})

        question_indexes =
          case Map.get(question_indexes, quiz_id, -1) do
            -1 -> Map.put(question_indexes, quiz_id, 0)
            index -> Map.put(question_indexes, quiz_id, index)
          end

        updated_socket_acc =
          socket_acc
          |> assign(:question_indexes, question_indexes)

        quiz_html =
          %{quiz_id: quiz_id, user_id: socket.assigns.current_user.id}
          |> Quizzes.get_started_quiz()
          |> render_quiz_html(question_indexes, sequences)

        updated_content_acc =
          String.replace(content_acc, "[quiz #{quiz_id}]", quiz_html)

        {updated_content_acc, updated_socket_acc}
      end)

    {
      updated_content,
      updated_socket
    }
  end

  defp render_quiz_html(
         %{started: true, id: quiz_id} = quiz,
         question_indexes,
         sequences
       ) do
    question_index = Map.get(question_indexes, quiz_id)
    question = Enum.at(quiz.questions, question_index)

    quiz_html =
      render_quiz(%{
        quiz: quiz,
        question: question,
        question_index: question_index,
        sequences: sequences,
        has_answer: has_answer?(question),
        correct_ids:
          case Enum.at(question.answered_questions, 0) do
            %Ecampus.Quizzes.AnsweredQuestion{answer: answer} when not is_nil(answer) ->
              Map.get(answer, "correct", [])

            _ ->
              []
          end,
        answered_ids:
          case Enum.at(question.answered_questions, 0) do
            %Ecampus.Quizzes.AnsweredQuestion{answer: answer} when not is_nil(answer) ->
              Map.get(answer, "answer_ids", [])

            _ ->
              []
          end
      })
      |> Phoenix.HTML.Safe.to_iodata()
      |> to_string()

    if Enum.all?(quiz.questions, &has_answer?(&1)) do
      quiz_html
    else
      quiz_html <> @stop_rendering_flag
    end
  end

  defp render_quiz_html(quiz, _, _) do
    render_quiz(%{
      quiz: quiz,
      question: nil,
      question_index: 0,
      sequences: %{},
      has_answer: false,
      correct_ids: [],
      answered_ids: []
    })
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
    |> Kernel.<>(@stop_rendering_flag)
  end

  defp has_answer?(%Ecampus.Quizzes.Question{answered_questions: answered_questions}) do
    case Enum.at(answered_questions, 0) do
      %Ecampus.Quizzes.AnsweredQuestion{answer: answer} when not is_nil(answer) -> true
      _ -> false
    end
  end
end
