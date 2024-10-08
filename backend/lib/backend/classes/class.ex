defmodule Backend.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:begin_date, :classroom, :lesson_id, :group_id],
    sortable: [:begin_date, :classroom, :lesson_id, :group_id],
    max_limit: 100,
    default_limit: 10
  }

  schema "classes" do
    field(:begin_date, :utc_datetime)
    field(:classroom, :string)
    belongs_to(:lesson, Backend.Lessons.Lesson)
    belongs_to(:group, Backend.Groups.Group)

    many_to_many(:teachers, Backend.Accounts.Account,
      join_through: "taught_classes",
      join_keys: [class_id: :id, taught_by_id: :id]
    )

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:begin_date, :classroom, :lesson_id, :group_id])
    |> validate_required([:begin_date, :classroom, :lesson_id, :group_id])
    |> foreign_key_constraint(:lesson_id)
    |> foreign_key_constraint(:group_id)
  end
end
