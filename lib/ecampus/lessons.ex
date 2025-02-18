defmodule Ecampus.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Lessons.Lesson
  alias Ecampus.Quizzes.Quiz
  alias Ecampus.Quizzes.Question
  alias Ecampus.Quizzes.Answer

  @doc """
  Returns the list of lessons for a given subject.

  ## Examples

  @doc \"""
  Returns the list of lessons.

  ## Examples

      iex> list_lessons()
      [%Lesson{}, ...]

  """
  def list_lessons do
    Repo.all(Lesson) |> Repo.preload(:subject)
  end

  @doc """
  Gets a single lesson.

  Raises `Ecto.NoResultsError` if the Lesson does not exist.

  ## Examples

      iex> get_lesson!(123)
      %Lesson{}

      iex> get_lesson!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson!(id), do: Repo.get!(Lesson, id) |> Repo.preload(:subject)

  @doc """
  Creates a lesson.

  ## Examples

      iex> create_lesson(%{field: value})
      {:ok, %Lesson{}}

      iex> create_lesson(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson(attrs \\ %{}) do
    changeset =
      %Lesson{}
      |> Lesson.changeset(attrs)

    with {:ok, lesson} <- Repo.insert(changeset) do
      {:ok, Repo.preload(lesson, [:subject])}
    end
  end

  @doc """
  Updates a lesson.

  ## Examples

      iex> update_lesson(lesson, %{field: new_value})
      {:ok, %Lesson{}}

      iex> update_lesson(lesson, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson(%Lesson{} = lesson, attrs) do
    changeset =
      lesson
      |> Lesson.changeset(attrs)

    with {:ok, lesson} <- Repo.update(changeset) do
      {:ok, Repo.preload(lesson, [:subject])}
    end
  end

  @doc """
  Deletes a lesson.

  ## Examples

      iex> delete_lesson(lesson)
      {:ok, %Lesson{}}

      iex> delete_lesson(lesson)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson changes.

  ## Examples

      iex> change_lesson(lesson)
      %Ecto.Changeset{data: %Lesson{}}

  """
  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  alias Ecampus.Lessons.LessonTopic

  @doc """
  Returns the list of lesson_topics.

  ## Examples

      iex> list_lesson_topics()
      [%LessonTopic{}, ...]

  """
  def list_lesson_topics(params \\ %{}) do
    query = LessonTopic |> preload([:lesson])

    query =
      Enum.reduce(params, query, fn
        {"lesson_id", lesson_id}, acc ->
          from lt in acc, where: lt.lesson_id == ^lesson_id

        _, acc ->
          acc
      end)

    query =
      query
      |> order_by([lt], asc: lt.sort_order)
      |> order_by([lt], asc: lt.id)

    Repo.all(query)
  end

  @doc """
  Gets a single lesson_topic.

  Raises `Ecto.NoResultsError` if the Lesson topic does not exist.

  ## Examples

      iex> get_lesson_topic(123)
      %LessonTopic{}

      iex> get_lesson_topic(456)
      nil

  """
  def get_lesson_topic(id), do: Repo.get(LessonTopic, id) |> Repo.preload(:lesson)

  @doc """
  Creates a lesson_topic.

  ## Examples

      iex> create_lesson_topic(%{field: value})
      {:ok, %LessonTopic{}}

      iex> create_lesson_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson_topic(attrs \\ %{}) do
    changeset =
      %LessonTopic{}
      |> LessonTopic.changeset(attrs)

    with {:ok, lesson_topic} <- Repo.insert(changeset) do
      {:ok, Repo.preload(lesson_topic, [:lesson])}
    end
  end

  @doc """
  Updates a lesson_topic.

  ## Examples

      iex> update_lesson_topic(lesson_topic, %{field: new_value})
      {:ok, %LessonTopic{}}

      iex> update_lesson_topic(lesson_topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson_topic(%LessonTopic{} = lesson_topic, attrs) do
    changeset =
      lesson_topic
      |> LessonTopic.changeset(attrs)

    with {:ok, lesson_topic} <- Repo.update(changeset) do
      {:ok, Repo.preload(lesson_topic, [:lesson])}
    end
  end

  @doc """
  Deletes a lesson_topic.

  ## Examples

      iex> delete_lesson_topic(lesson_topic)
      {:ok, %LessonTopic{}}

      iex> delete_lesson_topic(lesson_topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson_topic(%LessonTopic{} = lesson_topic) do
    Repo.delete(lesson_topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson_topic changes.

  ## Examples

      iex> change_lesson_topic(lesson_topic)
      %Ecto.Changeset{data: %LessonTopic{}}

  """
  def change_lesson_topic(%LessonTopic{} = lesson_topic, attrs \\ %{}) do
    LessonTopic.changeset(lesson_topic, attrs)
  end

  def export_lesson(lesson_id) do
    lesson = Repo.get!(Lesson, lesson_id) |> Repo.preload([:lesson_topics, :quizzes])
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
