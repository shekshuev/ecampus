defmodule Ecampus.Lessons do
  @moduledoc """
  The Lessons context.

  Provides functions for listing, retrieving, creating, updating,
  deleting and importing/exporting lessons with associated topics and quizzes.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Lessons.{Lesson, LessonTopic}

  @doc """
  Returns a paginated, filtered, and sorted list of lessons using Flop.

  ## Examples

      iex> list_lessons(%{"order_by" => "title", "limit" => 10})
      {[%Lesson{}, ...], %Flop.Meta{}}
  """
  @spec list_lessons(map()) :: {[Lesson.t()], Flop.Meta.t()} | {:error, Flop.Meta.t()}
  def list_lessons(params) do
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

  @spec list_lessons_topics(map()) :: {[LessonTopic.t()], Flop.Meta.t()} | {:error, Flop.Meta.t()}
  def list_lessons_topics(params) do
    Flop.validate_and_run!(LessonTopic, params, for: LessonTopic, replace_invalid_params: true)
  end

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
end
