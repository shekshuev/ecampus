defmodule Ecampus.Lessons.Lesson do
  @moduledoc """
  The Lesson context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    field :title, :string
    field :topic, :string
    field :objectives, :string
    field :is_draft, :boolean, default: false
    field :hours_count, :integer, default: 2
    field :sort_order, :integer, default: 0
    belongs_to(:subject, Ecampus.Subjects.Subject)

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
