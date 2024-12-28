defmodule Ecampus.Quizzes.AnsweredQuestion do
  @moduledoc """
  The Answered Quiz Question context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "answered_questions" do
    field :answer, :map

    belongs_to :user, Ecampus.Accounts.User
    belongs_to :question, Ecampus.Quizzes.Question
    belongs_to :quiz, Ecampus.Quizzes.Quiz

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(answered_question, attrs) do
    answered_question
    |> cast(attrs, [:answer, :user_id, :question_id, :quiz_id])
    |> validate_required([:user_id, :question_id, :quiz_id])
    |> foreign_key_constraint(:user_id, message: "User must exist")
    |> foreign_key_constraint(:question_id, message: "Question must exist")
  end
end
