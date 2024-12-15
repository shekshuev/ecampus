defmodule Ecampus.Classes.Class do
  @moduledoc """
  The Class context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:begin_date, :end_date, :classroom, :group_id, :lesson_id],
    sortable: [:begin_date, :end_date, :classroom, :group_id, :lesson_id]
  }

  schema "classes" do
    field :begin_date, :utc_datetime
    field :end_date, :utc_datetime
    field :classroom, :string
    belongs_to :lesson, Ecampus.Lessons.Lesson
    belongs_to :group, Ecampus.Groups.Group

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:begin_date, :end_date, :classroom, :group_id, :lesson_id])
    |> validate_required([:begin_date, :end_date, :classroom, :group_id, :lesson_id])
  end
end
