defmodule Ecampus.Lessons.Lesson do
  @moduledoc """
  The `Lesson` schema represents a unit of instruction within a subject.

  A lesson may include metadata like title, topic, objectives, and duration.
  It belongs to a subject and can have many associated lesson topics and quizzes.

  This schema is used throughout the application for creating, updating,
  listing, and exporting lesson content.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :topic, :subject_id, :hours_count],
    sortable: [:id, :title, :topic, :hours_count, :sort_order]
  }

  @type t :: %__MODULE__{
          id: integer(),
          title: String.t(),
          topic: String.t(),
          objectives: String.t(),
          is_draft: boolean(),
          hours_count: integer(),
          sort_order: integer(),
          subject_id: integer(),
          subject: Ecampus.Subjects.Subject.t() | Ecto.Association.NotLoaded.t(),
          quizzes: [Ecampus.Quizzes.Quiz.t()] | Ecto.Association.NotLoaded.t(),
          lesson_topics: [Ecampus.Lessons.LessonTopic.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
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
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
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
