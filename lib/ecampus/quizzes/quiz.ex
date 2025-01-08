defmodule Ecampus.Quizzes.Quiz do
  @moduledoc """
  The Quiz context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :lesson_id], sortable: [:title, :id]
  }

  schema "quizzes" do
    field :type, Ecto.Enum, values: [:quiz, :survey]
    field :description, :string
    field :title, :string
    field :questions_per_attempt, :integer
    belongs_to :lesson, Ecampus.Lessons.Lesson
    has_many :questions, Ecampus.Quizzes.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:title, :description, :questions_per_attempt, :lesson_id, :type])
    |> validate_required([:title, :description, :questions_per_attempt, :lesson_id, :type])
  end
end
