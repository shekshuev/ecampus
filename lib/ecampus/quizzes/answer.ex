defmodule Ecampus.Quizzes.Answer do
  @moduledoc """
  The Quiz Question context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    field :title, :string
    field :subtitle, :string
    field :is_correct, :boolean, default: false
    field :sequence_order_number, :integer, default: 0
    belongs_to :question, Ecampus.Quizzes.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:title, :subtitle, :is_correct, :sequence_order_number, :question_id])
    |> validate_required([:title, :is_correct, :question_id])
  end
end
