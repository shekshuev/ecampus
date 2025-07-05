defmodule Ecampus.Lessons.Lesson do
  @moduledoc """
  The Lesson context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :subject_id], sortable: [:sort_order]
  }

  schema "lessons" do
    field :title, :string
    field :topic, :string
    field :objectives, :string
    field :is_draft, :boolean, default: false
    field :hours_count, :integer, default: 2
    field :sort_order, :integer, default: 0
    belongs_to :subject, Ecampus.Subjects.Subject
    has_many :quizzes, Ecampus.Quizzes.Quiz
    has_many :lesson_topics, Ecampus.Lessons.LessonTopic

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [
      :title,
      :topic,
      :objectives,
      :is_draft,
      :hours_count,
      :sort_order,
      :subject_id
    ])
    |> validate_required([
      :title,
      :topic,
      :objectives,
      :is_draft,
      :hours_count,
      :sort_order,
      :subject_id
    ])
  end
end
