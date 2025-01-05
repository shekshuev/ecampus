defmodule Ecampus.Classes do
  @moduledoc """
  The Classes context.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  import Ecampus.Pagination

  alias Ecampus.Classes.Class
  alias Ecampus.Lessons.Lesson
  alias Ecampus.Quizzes.Quiz
  alias Ecampus.Quizzes.Question
  alias Ecampus.Quizzes.AnsweredQuestion
  alias Ecampus.Accounts.User

  @doc """
  Returns the list of classes.

  ## Examples

      iex> list_classes()
      [%Class{}, ...]

  """
  def list_classes(params \\ %{}) do
    filters = []

    filters =
      params
      |> Enum.reduce(filters, fn
        {"begin_date", value}, acc ->
          [%{field: :begin_date, value: value} | acc]

        {"end_date", value}, acc ->
          [%{field: :end_date, value: value} | acc]

        {"classroom", value}, acc ->
          [%{field: :classroom, value: value} | acc]

        {"lesson_id", value}, acc ->
          [%{field: :lesson_id, value: value} | acc]

        {"group_id", nil}, acc ->
          [%{field: :group_id, op: :empty, value: true} | acc]

        {"group_id", value}, acc ->
          [%{field: :group_id, value: value} | acc]

        _, acc ->
          acc
      end)

    Class
    |> preload([:lesson, :group, lesson: [:subject]])
    |> Flop.validate_and_run(
      %{
        page: Map.get(params, "page", 1),
        page_size: Map.get(params, "page_size", 10),
        filters: filters,
        order_by: [:begin_date, :end_date],
        order_directions: [:asc, :asc]
      },
      for: Class
    )
    |> with_pagination()
  end

  @doc """
  Gets a single class.

  ## Examples

      iex> get_class(123)
      %Class{}

      iex> get_class(456)
      nil

  """
  def get_class(id),
    do: Repo.get(Class, id) |> Repo.preload([:lesson, :group, lesson: [:subject]])

  @doc """
  Gets a incoming one class for current date

  ## Examples

      iex> get_class()
      %Class{}

      iex> get_class()
      nil

  """
  def get_incoming_class(%{group_id: current_group_id}),
    do:
      Class
      |> where(
        [c],
        c.begin_date >= ^NaiveDateTime.local_now() and c.group_id == ^current_group_id
      )
      |> order_by([c], asc: c.begin_date)
      |> limit(1)
      |> Repo.one()
      |> Repo.preload([:lesson, :group, lesson: [:subject]])

  def get_stats(%{id: current_user_id, group_id: current_group_id}) do
    query =
      from c in Class,
        where: c.group_id == ^current_group_id,
        select: %{
          completed_lessons: fragment("COUNT(*) FILTER (WHERE ? < NOW())", c.end_date),
          total_lessons: count(c.id)
        }

    stats = Repo.one(query)

    percentage =
      if stats.total_lessons > 0 do
        round(stats.completed_lessons * 100 / stats.total_lessons)
      else
        0
      end

    stats = Map.put(stats, :percentage, percentage)

    query =
      from l in Lesson,
        join: c in Class,
        on: c.lesson_id == l.id,
        join: q in Quiz,
        on: q.lesson_id == l.id,
        left_join: aq in AnsweredQuestion,
        on: aq.quiz_id == q.id and aq.user_id == ^current_user_id,
        left_join:
          max_scores in subquery(
            from quest in Question,
              group_by: quest.quiz_id,
              select: %{
                quiz_id: quest.quiz_id,
                max_score: coalesce(sum(quest.grade), 0)
              }
          ),
        on: max_scores.quiz_id == q.id,
        where:
          c.end_date < ^NaiveDateTime.local_now() and q.type == :quiz and
            c.group_id == ^current_group_id,
        group_by: [c.id, l.id, max_scores.max_score],
        order_by: [desc: c.end_date],
        limit: 5,
        select: %{
          lesson_title: l.title,
          max_score: coalesce(max_scores.max_score, 0),
          actual_score: fragment("COALESCE(SUM((?->>'grade')::numeric), 0)", aq.answer)
        }

    last_quizzes = Repo.all(query)

    stats = Map.put(stats, :last_quizzes, last_quizzes)

    query =
      from q in Quiz,
        join: l in Lesson,
        on: q.lesson_id == l.id,
        join: c in Class,
        on: c.lesson_id == l.id,
        join: quest in Question,
        on: quest.quiz_id == q.id,
        left_join: aq in AnsweredQuestion,
        on: aq.quiz_id == q.id and aq.user_id == ^current_user_id,
        where:
          c.end_date < ^NaiveDateTime.local_now() and q.type == :quiz and
            c.group_id == ^current_group_id,
        group_by: q.id,
        select: %{
          max_score: coalesce(sum(quest.grade), 0),
          actual_score:
            fragment(
              """
                COALESCE(SUM(CASE WHEN ? IS NOT NULL THEN (?->>'grade')::numeric ELSE 0 END), 0)
              """,
              aq.answer,
              aq.answer
            )
        }

    results = Repo.all(query)

    total_max_score =
      Enum.reduce(results, 0, fn %{max_score: max_score}, acc -> acc + max_score end)

    total_actual_score =
      Enum.reduce(results, 0, fn %{actual_score: actual_score}, acc ->
        acc + Decimal.to_integer(actual_score)
      end)

    total_score =
      if total_max_score > 0 do
        Float.round(total_actual_score * 100 / total_max_score, 2)
      else
        0
      end

    stats = Map.put(stats, :total_score, total_score)

    stats
  end

  def rank_students_in_group(nil), do: []

  def rank_students_in_group(current_group_id) do
    query =
      from u in User,
        where: u.group_id == ^current_group_id,
        join: c in Class,
        on: c.group_id == u.group_id,
        join: l in Lesson,
        on: c.lesson_id == l.id,
        join: q in Quiz,
        on: q.lesson_id == l.id,
        join: quest in Question,
        on: quest.quiz_id == q.id,
        left_join: aq in AnsweredQuestion,
        on: aq.quiz_id == q.id and aq.user_id == u.id,
        group_by: [u.id, q.id],
        select: %{
          user_id: u.id,
          email: u.email,
          max_score: coalesce(sum(quest.grade), 0),
          actual_score:
            fragment(
              """
              COALESCE(SUM(CASE WHEN ? IS NOT NULL THEN (?->>'grade')::numeric ELSE 0 END), 0)
              """,
              aq.answer,
              aq.answer
            )
        }

    results = Repo.all(query)

    student_scores =
      results
      |> Enum.group_by(& &1.user_id)
      |> Enum.map(fn {user_id, scores} ->
        total_max_score = Enum.sum(Enum.map(scores, & &1.max_score))

        total_actual_score =
          Enum.sum(
            Enum.map(scores, fn %{actual_score: actual_score} ->
              Decimal.to_integer(actual_score)
            end)
          )

        total_score =
          if total_max_score > 0 do
            Float.round(total_actual_score * 100 / total_max_score, 2)
          else
            0
          end

        %{user_id: user_id, email: scores |> hd() |> Map.get(:email), score: total_score}
      end)

    student_scores
    |> Enum.sort_by(& &1.score, :desc)
  end

  @doc """
  Creates a class.

  ## Examples

      iex> create_class(%{field: value})
      {:ok, %Class{}}

      iex> create_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_class(attrs \\ %{}) do
    changeset =
      %Class{}
      |> Class.changeset(attrs)

    with {:ok, class} <- Repo.insert(changeset) do
      {:ok, Repo.preload(class, [:lesson, :group, lesson: [:subject]])}
    end
  end

  @doc """
  Updates a class.

  ## Examples

      iex> update_class(class, %{field: new_value})
      {:ok, %Class{}}

      iex> update_class(class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_class(%Class{} = class, attrs) do
    changeset =
      class
      |> Class.changeset(attrs)

    with {:ok, class} <- Repo.update(changeset) do
      {:ok, Repo.preload(class, [:lesson, :group, lesson: [:subject]])}
    end
  end

  @doc """
  Deletes a class.

  ## Examples

      iex> delete_class(class)
      {:ok, %Class{}}

      iex> delete_class(class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking class changes.

  ## Examples

      iex> change_class(class)
      %Ecto.Changeset{data: %Class{}}

  """
  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end
end
