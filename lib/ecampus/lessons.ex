defmodule Ecampus.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  import Ecampus.Pagination

  alias Ecampus.Lessons.Lesson

  @doc """
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
    filters = []

    filters =
      params
      |> Enum.reduce(filters, fn
        {"lesson_id", lesson_id}, acc ->
          [%{field: :lesson_id, value: lesson_id} | acc]

        _, acc ->
          acc
      end)

    LessonTopic
    |> preload([:lesson])
    |> Flop.validate_and_run(
      %{
        page: Map.get(params, "page", 1),
        page_size: Map.get(params, "page_size", 10),
        filters: filters,
        order_by: [:sort_order, :id],
        order_directions: [:asc, :asc]
      },
      for: LessonTopic
    )
    |> with_pagination()
  end

  @doc """
  Gets a single lesson_topic.

  Raises `Ecto.NoResultsError` if the Lesson topic does not exist.

  ## Examples

      iex> get_lesson_topic!(123)
      %LessonTopic{}

      iex> get_lesson_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson_topic!(id), do: Repo.get!(LessonTopic, id) |> Repo.preload(:lesson)

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
end
