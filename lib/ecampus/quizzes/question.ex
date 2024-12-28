defmodule Ecampus.Quizzes.Question do
  @moduledoc """
  The Quiz Question context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :subtitle, :quiz_id, :type],
    sortable: [:title, :subtitle, :id, :quiz_id, :type]
  }

  schema "questions" do
    field :type, Ecto.Enum, values: [:multiple, :sequence]
    field :title, :string
    field :subtitle, :string
    field :grade, :integer
    field :show_correct_answer, :boolean, default: false
    belongs_to :quiz, Ecampus.Quizzes.Quiz
    has_many :answers, Ecampus.Quizzes.Answer
    has_many :answered_questions, Ecampus.Quizzes.AnsweredQuestion

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:type, :title, :subtitle, :grade, :show_correct_answer, :quiz_id])
    |> validate_required([:type, :title, :subtitle, :grade, :show_correct_answer, :quiz_id])
  end
end
