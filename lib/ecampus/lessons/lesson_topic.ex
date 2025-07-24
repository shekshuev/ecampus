defmodule Ecampus.Lessons.LessonTopic do
  @moduledoc """
  The `LessonTopic` schema represents an individual topic within a lesson.

  Each lesson topic includes a title, optional content (in Markdown or text),
  and a sort order to define its position within the lesson.

  It belongs to a lesson and is used to structure the educational content
  into logical segments.

  This schema is used for displaying, editing, and organizing content blocks
  within a lesson.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :lesson_id, :id], sortable: [:sort_order, :id, :lesson_id, :title]
  }

  @type t :: %__MODULE__{
          id: integer(),
          title: String.t(),
          content: String.t(),
          sort_order: integer(),
          lesson_id: integer(),
          lesson: Ecampus.Lessons.Lesson.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "lesson_topics" do
    field :title, :string
    field :content, :string
    field :sort_order, :integer
    belongs_to :lesson, Ecampus.Lessons.Lesson

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(lesson_topic, attrs) do
    lesson_topic
    |> cast(attrs, [:title, :content, :sort_order, :lesson_id])
    |> validate_required([:title, :content, :sort_order, :lesson_id])
  end
end
