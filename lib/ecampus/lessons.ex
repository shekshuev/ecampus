defmodule Ecampus.Lessons do
  @moduledoc """
  The Lessons context.

  Provides functions for listing, retrieving, creating, updating,
  deleting and importing/exporting lessons with associated topics and quizzes.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Lessons.{Lesson, LessonTopic}
  alias Ecampus.Quizzes.{Quiz, Question, Answer}

  @doc """
  Returns a paginated, filtered, and sorted list of lessons using Flop.

  ## Examples

      iex> list_lessons(%{"order_by" => "title", "limit" => 10})
      {[%Lesson{}, ...], %Flop.Meta{}}
  """
  @spec list_lessons(map()) :: {[Lesson.t()], Flop.Meta.t()} | {:error, Flop.Meta.t()}
  def list_lessons(params) do
    params |> IO.inspect(label: "list_lessons params")
    Flop.validate_and_run!(Lesson, params, for: Lesson, replace_invalid_params: true)
  end

  @doc """
  Gets a single lesson by ID with its subject preloaded.

  Raises `Ecto.NoResultsError` if the lesson does not exist.
  """
  @spec get_lesson!(integer()) :: Lesson.t()
  def get_lesson!(id), do: Repo.get!(Lesson, id) |> Repo.preload(:subject)

  @doc """
  Creates a new lesson.

  ## Examples

      iex> create_lesson(%{title: "Intro"})
      {:ok, %Lesson{}}
  """
  @spec create_lesson(map()) :: {:ok, Lesson.t()} | {:error, Ecto.Changeset.t()}
  def create_lesson(attrs \\ %{}) do
    %Lesson{}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, lesson} -> {:ok, Repo.preload(lesson, [:subject])}
      error -> error
    end
  end

  @doc """
  Updates an existing lesson.

  ## Examples

      iex> update_lesson(lesson, %{title: "Updated"})
      {:ok, %Lesson{}}
  """
  @spec update_lesson(Lesson.t(), map()) :: {:ok, Lesson.t()} | {:error, Ecto.Changeset.t()}
  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, lesson} -> {:ok, Repo.preload(lesson, [:subject])}
      error -> error
    end
  end

  @doc """
  Deletes a lesson.
  """
  @spec delete_lesson(Lesson.t()) :: {:ok, Lesson.t()} | {:error, Ecto.Changeset.t()}
  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  @doc """
  Returns a changeset for tracking lesson changes.
  """
  @spec change_lesson(Lesson.t(), map()) :: Ecto.Changeset.t()
  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  # ----- LessonTopic CRUD -----

  @doc """
  Returns a list of lesson topics, filtered by lesson_id and ordered by sort_order and id.
  """
  @spec list_lesson_topics(map()) :: [LessonTopic.t()]
  def list_lesson_topics(params \\ %{}) do
    LessonTopic
    |> preload([:lesson])
    |> filter_lesson_topics(params)
    |> order_by([lt], asc: lt.sort_order)
    |> order_by([lt], asc: lt.id)
    |> Repo.all()
  end

  defp filter_lesson_topics(query, %{"lesson_id" => lesson_id}) do
    from lt in query, where: lt.lesson_id == ^lesson_id
  end

  defp filter_lesson_topics(query, _), do: query

  @doc """
  Gets a single lesson topic with its lesson preloaded.
  """
  @spec get_lesson_topic(integer()) :: LessonTopic.t() | nil
  def get_lesson_topic(id), do: Repo.get(LessonTopic, id) |> Repo.preload(:lesson)

  @doc """
  Creates a lesson topic.
  """
  @spec create_lesson_topic(map()) ::
          {:ok, LessonTopic.t()} | {:error, Ecto.Changeset.t()}
  def create_lesson_topic(attrs \\ %{}) do
    %LessonTopic{}
    |> LessonTopic.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, lt} -> {:ok, Repo.preload(lt, [:lesson])}
      error -> error
    end
  end

  @doc """
  Updates a lesson topic.
  """
  @spec update_lesson_topic(LessonTopic.t(), map()) ::
          {:ok, LessonTopic.t()} | {:error, Ecto.Changeset.t()}
  def update_lesson_topic(%LessonTopic{} = lt, attrs) do
    lt
    |> LessonTopic.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, lt} -> {:ok, Repo.preload(lt, [:lesson])}
      error -> error
    end
  end

  @doc """
  Deletes a lesson topic.
  """
  @spec delete_lesson_topic(LessonTopic.t()) ::
          {:ok, LessonTopic.t()} | {:error, Ecto.Changeset.t()}
  def delete_lesson_topic(%LessonTopic{} = lt) do
    Repo.delete(lt)
  end

  @doc """
  Returns a changeset for tracking lesson topic changes.
  """
  @spec change_lesson_topic(LessonTopic.t(), map()) :: Ecto.Changeset.t()
  def change_lesson_topic(%LessonTopic{} = lt, attrs \\ %{}) do
    LessonTopic.changeset(lt, attrs)
  end

  # ----- Export / Import -----

  @doc """
  Exports a lesson, its topics, and quizzes with nested questions and answers to a JSON string.
  """
  @spec export_lesson(integer()) :: String.t()
  def export_lesson(lesson_id) do
    lesson =
      Repo.get!(Lesson, lesson_id)
      |> Repo.preload([:lesson_topics, :quizzes])

    quizzes = Repo.preload(lesson.quizzes, questions: [:answers])

    %{
      title: lesson.title,
      topic: lesson.topic,
      objectives: lesson.objectives,
      is_draft: lesson.is_draft,
      hours_count: lesson.hours_count,
      sort_order: lesson.sort_order,
      subject_id: nil,
      lesson_topics:
        Enum.map(lesson.lesson_topics, fn topic ->
          %{
            title: topic.title,
            content: topic.content,
            sort_order: topic.sort_order
          }
        end),
      quizzes:
        Enum.map(quizzes, fn quiz ->
          %{
            title: quiz.title,
            description: quiz.description,
            questions_per_attempt: quiz.questions_per_attempt,
            type: quiz.type,
            questions:
              Enum.map(quiz.questions, fn question ->
                %{
                  type: question.type,
                  title: question.title,
                  subtitle: question.subtitle,
                  grade: question.grade,
                  show_correct_answer: question.show_correct_answer,
                  sort_order: question.sort_order,
                  answers:
                    Enum.map(question.answers, fn answer ->
                      %{
                        title: answer.title,
                        subtitle: answer.subtitle,
                        is_correct: answer.is_correct,
                        sequence_order_number: answer.sequence_order_number,
                        sort_order: answer.sort_order
                      }
                    end)
                }
              end)
          }
        end)
    }
    |> Jason.encode!()
  end

  @doc """
  Imports a lesson with lesson topics and quizzes from JSON data and attaches it to a subject.

  Returns the inserted lesson ID.
  """
  @spec import_lesson(String.t(), integer()) :: integer()
  def import_lesson(json_data, subject_id) do
    {:ok, lesson_data} = Jason.decode(json_data)

    Repo.transaction(fn ->
      lesson =
        %Lesson{}
        |> Lesson.changeset(Map.put(lesson_data, "subject_id", subject_id))
        |> Repo.insert!()

      Enum.each(lesson_data["lesson_topics"], fn topic_data ->
        %LessonTopic{}
        |> LessonTopic.changeset(Map.put(topic_data, "lesson_id", lesson.id))
        |> Repo.insert!()
      end)

      Enum.each(lesson_data["quizzes"], fn quiz_data ->
        quiz =
          %Quiz{}
          |> Quiz.changeset(Map.put(quiz_data, "lesson_id", lesson.id))
          |> Repo.insert!()

        Enum.each(quiz_data["questions"], fn question_data ->
          question =
            %Question{}
            |> Question.changeset(Map.put(question_data, "quiz_id", quiz.id))
            |> Repo.insert!()

          Enum.each(question_data["answers"], fn answer_data ->
            %Answer{}
            |> Answer.changeset(Map.put(answer_data, "question_id", question.id))
            |> Repo.insert!()
          end)
        end)
      end)

      lesson.id
    end)
  end
end
