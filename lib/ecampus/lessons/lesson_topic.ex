defmodule Ecampus.Lessons.LessonTopic do
  @moduledoc """
  The Lesson Topic context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :lesson_id], sortable: [:sort_order, :id]
  }

  schema "lesson_topics" do
    field :title, :string
    field :content, :string
    field :sort_order, :integer
    belongs_to :lesson, Ecampus.Lessons.Lesson

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson_topic, attrs) do
    lesson_topic
    |> cast(attrs, [:title, :content, :sort_order, :lesson_id])
    |> validate_required([:title, :content, :sort_order, :lesson_id])
  end
end
