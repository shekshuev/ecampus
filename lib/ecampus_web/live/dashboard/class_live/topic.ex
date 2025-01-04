defmodule EcampusWeb.Dashboard.ClassLive.Topic do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Classes
  alias Ecampus.Lessons
  alias Ecampus.Quizzes

  @stop_rendering_flag "<!-- Rendering stopped -->"

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
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
      {%{available: false}, _} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/dashboard/classes/#{class_id}")}

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
    answer =
      case question_type do
        "multiple" ->
          %{
            answer_ids:
              params
              |> Enum.filter(fn {key, value} ->
                String.starts_with?(key, "answer-") and value == "true"
              end)
              |> Enum.map(fn {key, _value} ->
                Regex.run(~r/answer-(\d+)/, key)
                |> List.last()
                |> String.to_integer()
              end)
          }

        "sequence" ->
          %{
            answer_ids:
              Map.get(socket.assigns, :sequences, %{})
              |> Map.get("#{quiz_id}-#{question_id}", [])
              |> Enum.reverse()
          }

        "open" ->
          %{answer_text: Map.get(params, "text", nil)}

        _ ->
          nil
      end

    Quizzes.answer_question(%{
      question_id: question_id,
      user_id: socket.assigns.current_user.id,
      answer: answer
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

  defp parse_markdown(lesson_topic, socket) do
    {replaced_content, socket} =
      lesson_topic.content
      |> Earmark.as_html!()
      |> replace_chat_bubble()
      |> replace_quiz(socket)

    html_content =
      replaced_content
      |> String.split(@stop_rendering_flag)
      |> List.first()

    {Map.put(lesson_topic, :html_content, html_content), socket}
  end

  # Chat bubble begin

  defp replace_chat_bubble(content) do
    regex = ~r/\b(pos|avatar|name|text)=\[(.*?)\]/

    content
    |> String.split("\n", trim: true)
    |> Enum.map_join("\n", &process_line(&1, regex))
  end

  defp process_line(line, regex) do
    if String.contains?(line, "[chat-bubble") do
      line
      |> extract_params(regex)
      |> render_chat_bubble_html()
    else
      line
    end
  end

  defp extract_params(line, regex) do
    Regex.scan(regex, line)
    |> Enum.map(fn [_, key, value] -> {String.to_atom(key), value} end)
    |> Map.new()
  end

  defp render_chat_bubble_html(%{pos: pos, avatar: _, name: _, text: _} = params)
       when pos in ["left", "right"] do
    render_chat_bubble(params)
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end

  defp render_chat_bubble_html(_), do: ""

  defp render_chat_bubble(assigns) do
    ~H"""
    <div class={[
      "chat",
      @pos == "left" && "chat-start",
      @pos == "right" && "chat-end"
    ]}>
      <div class="chat-image avatar">
        <%= if @avatar != "" do %>
          <div class="w-10 rounded-full bg-neutral text-neutral-content ">
            <img alt="Tailwind CSS chat bubble component" src={@avatar} />
          </div>
        <% else %>
          <div class="w-10 rounded-full bg-neutral text-neutral-content text-center">
            <div class="w-full h-full text-2xl flex items-center justify-center">
              {@name |> String.first()}
            </div>
          </div>
        <% end %>
      </div>
      <div class="chat-header">
        {@name}
      </div>
      <div class="chat-bubble">{@text}</div>
    </div>
    """
  end

  # chat bubble end

  # Quiz section begin

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
        question: %{question | subtitle: Earmark.as_html!(question.subtitle)},
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

    if Enum.all?(quiz.questions, &has_answer?(&1)) ||
         (quiz.type == :survey && quiz.survey_done == true) do
      quiz_html
    else
      quiz_html <> @stop_rendering_flag
    end
  end

  defp render_quiz_html(%{type: :survey, survey_done: true} = quiz, _, _) do
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

  defp render_quiz(assigns) do
    ~H"""
    <div class="card shadow-md">
      <%= if length(@quiz.questions) == 0 do %>
        <%= if @quiz.type == :survey && @quiz.survey_done == true do %>
          <div class="card-body">
            <span class="hero-hand-thumb-up h-12 w-12" />
            <h2 class="card-title my-0">{gettext("Thanks for feedback!")}</h2>
          </div>
        <% else %>
          <div class="card-body">
            <h2 class="card-title my-0">{@quiz.title}</h2>
            <p class="text-sm">{@quiz.description}</p>
            <div class="card-actions justify-end">
              <button phx-click="start-quiz" phx-value-quiz-id={@quiz.id} class="btn btn-primary">
                {gettext("Begin")}
              </button>
            </div>
          </div>
        <% end %>
      <% else %>
        <form class="card-body" phx-submit="answer-question">
          <.input name="question-id" type="hidden" value={@question.id} />
          <.input name="quiz-id" type="hidden" value={@quiz.id} />
          <h3 class="card-title my-0">{@question.title}</h3>
          <div class="prose">{raw(@question.subtitle)}</div>
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

          <%= if @question.type == :open do %>
            <.input name="question-type" type="hidden" value={:open} />
            <.input
              name="text"
              type="textarea"
              value={
                (@has_answer &&
                   Map.get(Enum.at(@question.answered_questions, 0).answer, "answer_text", "")) ||
                  ""
              }
              rows="6"
              disabled={@has_answer}
            />
            <%= if @has_answer do %>
              <p class={[
                "text-xs",
                Map.get(Enum.at(@question.answered_questions, 0).answer, "correct") == false &&
                  "text-error",
                Map.get(Enum.at(@question.answered_questions, 0).answer, "correct") == true &&
                  "text-success"
              ]}>
                {(Map.get(Enum.at(@question.answered_questions, 0).answer, "correct") == false &&
                    gettext("Wrong answer")) || ""}
                {(Map.get(Enum.at(@question.answered_questions, 0).answer, "correct") == true &&
                    gettext("Correct answer!")) || ""}
                {(Map.get(Enum.at(@question.answered_questions, 0).answer, "correct") == nil &&
                    gettext("Please, wait for manual answer check")) || ""}
              </p>
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
              <div class="divider">{gettext("Right answer")}</div>
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
                    {gettext("No item selected")}
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

                <div class="divider">{gettext("Please select in correct order")}</div>
                <%= if length(@question.answers) == length(Map.get(@sequences,"#{@quiz.id}-#{@question.id}", [])) do %>
                  <div class="card bg-base-200 rounded-box min-h-16 p-4 flex flex-row justify-center items-center ">
                    {gettext("No items left")}
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
                class="btn btn-neutral"
              >
                {gettext("Prev")}
              </button>
            <% end %>
            <%= if Enum.at(@question.answered_questions, 0).answer == nil do %>
              <button type="submit" class="btn btn-primary">
                {gettext("Submit")}
              </button>
            <% else %>
              <%= if @question_index < length(@quiz.questions) - 1 do %>
                <button
                  type="button"
                  phx-click="next-question"
                  phx-value-quiz-id={@quiz.id}
                  class="btn btn-neutral"
                >
                  {gettext("Next")}
                </button>
              <% end %>
            <% end %>
          </div>
        </form>
      <% end %>
    </div>
    """
  end

  # Quiz section end
end
