defmodule Ecampus.Quizzes do
  @moduledoc """
  The Quizzes context.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  import Ecampus.Pagination

  alias Ecampus.Quizzes.Quiz
  alias Ecampus.Quizzes.AnsweredQuestion

  @doc """
  Returns the list of quizzes.

  ## Examples

      iex> list_quizzes()
      [%Quiz{}, ...]

  """
  def list_quizzes(params \\ %{}) do
    filters = []

    filters =
      params
      |> Enum.reduce(filters, fn
        {"lesson_id", lesson_id}, acc ->
          [%{field: :lesson_id, value: lesson_id} | acc]

        _, acc ->
          acc
      end)

    Quiz
    |> preload([:lesson, :questions])
    |> Flop.validate_and_run(
      %{
        page: Map.get(params, "page", 1),
        page_size: Map.get(params, "page_size", 10),
        filters: filters,
        order_by: [:id],
        order_directions: [:asc]
      },
      for: Quiz
    )
    |> with_pagination()
  end

  def list_all_quizzes(params \\ %{}) do
    Quiz
    |> preload([:lesson, :questions])
    |> apply_filters(params)
    |> Repo.all()
  end

  defp apply_filters(query, params) do
    Enum.reduce(params, query, fn
      {"lesson_id", lesson_id}, query ->
        where(query, [q], q.lesson_id == ^lesson_id)

      _, query ->
        query
    end)
  end

  @doc """
  Gets a single quiz.

  Raises `Ecto.NoResultsError` if the Quiz does not exist.

  ## Examples

      iex> get_quiz(123)
      %Quiz{}

      iex> get_quiz(456)
      nil

  """
  def get_quiz(id),
    do: Repo.get(Quiz, id) |> Repo.preload([:lesson, :questions, questions: [:answers]])

  def get_started_quiz(%{
        quiz_id: quiz_id,
        user_id: user_id
      }) do
    Repo.get!(Ecampus.Quizzes.Quiz, quiz_id)
    |> Repo.preload(
      questions:
        from(q in Ecampus.Quizzes.Question,
          join: aq in assoc(q, :answered_questions),
          where: aq.user_id == ^user_id
        )
    )
    |> Repo.preload(questions: [:answers, :answered_questions])
  end

  def start_quiz(%{
        quiz_id: quiz_id,
        user_id: user_id
      }),
      do:
        Repo.get!(Quiz, quiz_id)
        |> Repo.preload([:questions, questions: [:answers]])
        |> shuffle_and_get_question()
        |> create_empty_answered_questions(user_id)
        |> insert_empty_answered_questions()

  defp insert_empty_answered_questions(quiz) do
    Repo.transaction(fn ->
      Enum.each(quiz.questions, &Repo.insert(&1, []))
    end)
  end

  defp create_empty_answered_questions(%Quiz{} = quiz, user_id),
    do: %{
      quiz
      | questions:
          Enum.map(quiz.questions, fn question ->
            %AnsweredQuestion{}
            |> AnsweredQuestion.changeset(%{
              quiz_id: quiz.id,
              question_id: question.id,
              user_id: user_id,
              answer: nil
            })
          end)
    }

  defp shuffle_and_get_question(%Quiz{} = quiz),
    do: %{
      quiz
      | questions:
          Enum.shuffle(quiz.questions)
          |> Enum.take(quiz.questions_per_attempt)
    }

  def answer_question(%{
        question_id: question_id,
        user_id: user_id,
        answer: answer
      }) do
    case from(q in Ecampus.Quizzes.Question,
           join: aq in assoc(q, :answered_questions),
           where: aq.user_id == ^user_id and q.id == ^question_id and is_nil(aq.answer)
         )
         |> Repo.one()
         |> Repo.preload([:answers])
         |> apply_answer(answer) do
      nil ->
        {:error, "Already answered"}

      processed_answer ->
        Repo.update_all(
          from(aq in AnsweredQuestion,
            where: aq.user_id == ^user_id and aq.question_id == ^question_id
          ),
          set: [answer: processed_answer, updated_at: DateTime.utc_now()]
        )

        {:ok}
    end
  end

  defp apply_answer(%{type: :multiple} = question, %{answer_ids: answer_ids} = answer) do
    correct_ids =
      question.answers
      |> Enum.filter(& &1.is_correct)
      |> Enum.map(& &1.id)
      |> Enum.sort()

    answer_ids = answer_ids |> Enum.sort()

    if answer_ids == correct_ids do
      Map.merge(answer, %{grade: question.grade, correct: answer_ids})
    else
      points_per_answer = question.grade / length(correct_ids)

      correct_count =
        answer_ids
        |> Enum.filter(&Enum.member?(correct_ids, &1))
        |> length()

      incorrect_count = length(answer_ids) - correct_count

      Map.merge(answer, %{
        grade: max(0, points_per_answer * (correct_count - incorrect_count)),
        correct: correct_ids
      })
    end
  end

  defp apply_answer(nil, _), do: nil

  defp apply_answer(_question, answer) do
    Map.merge(answer, %{grade: 0})
  end

  @doc """
  Creates a quiz.

  ## Examples

      iex> create_quiz(%{field: value})
      {:ok, %Quiz{}}

      iex> create_quiz(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quiz(attrs \\ %{}) do
    changeset =
      %Quiz{}
      |> Quiz.changeset(attrs)

    with {:ok, quiz} <- Repo.insert(changeset) do
      {:ok, Repo.preload(quiz, [:lesson, :questions])}
    end
  end

  @doc """
  Updates a quiz.

  ## Examples

      iex> update_quiz(quiz, %{field: new_value})
      {:ok, %Quiz{}}

      iex> update_quiz(quiz, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quiz(%Quiz{} = quiz, attrs) do
    changeset =
      quiz
      |> Quiz.changeset(attrs)

    with {:ok, quiz} <- Repo.update(changeset) do
      {:ok, Repo.preload(quiz, [:lesson, :questions])}
    end
  end

  @doc """
  Deletes a quiz.

  ## Examples

      iex> delete_quiz(quiz)
      {:ok, %Quiz{}}

      iex> delete_quiz(quiz)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quiz(%Quiz{} = quiz) do
    Repo.delete(quiz)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quiz changes.

  ## Examples

      iex> change_quiz(quiz)
      %Ecto.Changeset{data: %Quiz{}}

  """
  def change_quiz(%Quiz{} = quiz, attrs \\ %{}) do
    Quiz.changeset(quiz, attrs)
  end

  alias Ecampus.Quizzes.Question

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions(params \\ %{}) do
    filters = []

    filters =
      params
      |> Enum.reduce(filters, fn
        {"quiz_id", quiz_id}, acc ->
          [%{field: :quiz_id, value: quiz_id} | acc]

        _, acc ->
          acc
      end)

    Question
    |> preload([:quiz, :answers])
    |> Flop.validate_and_run(
      %{
        page: Map.get(params, "page", 1),
        page_size: Map.get(params, "page_size", 10),
        filters: filters,
        order_by: [:id],
        order_directions: [:asc]
      },
      for: Quiz
    )
    |> with_pagination()
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question(123)
      %Question{}

      iex> get_question(456)
      nil

  """
  def get_question(id), do: Repo.get(Question, id) |> Repo.preload([:quiz, :answers])

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    changeset =
      %Question{}
      |> Question.changeset(attrs)

    with {:ok, question} <- Repo.insert(changeset) do
      {:ok, Repo.preload(question, [:quiz, :answers])}
    end
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    changeset =
      question
      |> Question.changeset(attrs)

    with {:ok, question} <- Repo.update(changeset) do
      {:ok, Repo.preload(question, [:quiz, :answers])}
    end
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  alias Ecampus.Quizzes.Answer

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers do
    Repo.all(Answer) |> Repo.preload(:question)
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_answer(id), do: Repo.get(Answer, id) |> Repo.preload(:question)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answer(attrs \\ %{}) do
    changeset =
      %Answer{}
      |> Answer.changeset(attrs)

    with {:ok, answer} <- Repo.insert(changeset) do
      {:ok, Repo.preload(answer, [:question])}
    end
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{} = answer, attrs) do
    changeset =
      answer
      |> Answer.changeset(attrs)

    with {:ok, answer} <- Repo.update(changeset) do
      {:ok, Repo.preload(answer, [:question])}
    end
  end

  @doc """
  Deletes a answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answer changes.

  ## Examples

      iex> change_answer(answer)
      %Ecto.Changeset{data: %Answer{}}

  """
  def change_answer(%Answer{} = answer, attrs \\ %{}) do
    Answer.changeset(answer, attrs)
  end

  alias Ecampus.Quizzes.AnsweredQuestion

  @doc """
  Returns the list of answered_questions.

  ## Examples

      iex> list_answered_questions()
      [%AnsweredQuestion{}, ...]

  """
  def list_answered_questions do
    Repo.all(AnsweredQuestion)
  end

  @doc """
  Gets a single answered_question.

  Raises `Ecto.NoResultsError` if the Answered question does not exist.

  ## Examples

      iex> get_answered_question(123)
      %AnsweredQuestion{}

      iex> get_answered_question(456)
      ** nil

  """
  def get_answered_question(%{user_id: user_id, question_id: question_id, quiz_id: quiz_id}),
    do:
      Repo.get_by(AnsweredQuestion, user_id: user_id, question_id: question_id, quiz_id: quiz_id)

  @doc """
  Creates a answered_question.

  ## Examples

      iex> create_answered_question(%{field: value})
      {:ok, %AnsweredQuestion{}}

      iex> create_answered_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answered_question(attrs \\ %{}) do
    %AnsweredQuestion{}
    |> AnsweredQuestion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answered_question changes.

  ## Examples

      iex> change_answered_question(answered_question)
      %Ecto.Changeset{data: %AnsweredQuestion{}}

  """
  def change_answered_question(%AnsweredQuestion{} = answered_question, attrs \\ %{}) do
    AnsweredQuestion.changeset(answered_question, attrs)
  end
end
