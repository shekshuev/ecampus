defmodule Ecampus.Specialities.Speciality do
  @moduledoc """
  Schema for representing an academic speciality.

  A speciality typically includes:
    - `code`: the unique identifier of the speciality.
    - `title`: the name of the speciality.
    - `description`: a brief description of what the speciality covers.

  This schema is stored in the `"specialities"` table.
  """

  use Ecto.Schema
  import Ecto.Changeset
  use Gettext, backend: EcampusWeb.Gettext

  @derive {
    Flop.Schema,
    filterable: [:code, :description, :title], sortable: [:code, :id, :title]
  }

  @type t :: %__MODULE__{
          id: integer() | nil,
          code: String.t(),
          title: String.t(),
          description: String.t(),
          groups: [Ecampus.Groups.Group.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "specialities" do
    field :code, :string
    field :description, :string
    field :title, :string

    has_many :groups, Ecampus.Groups.Group

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(speciality, attrs) do
    speciality
    |> cast(attrs, [:code, :description, :title])
    |> validate_required([:code, :title])
    |> validate_length(:code, min: 2, max: 20)
    |> validate_length(:description, min: 10, max: 500)
  end

  @doc false
  def delete_changeset(speciality) do
    Ecto.Changeset.change(speciality)
    |> foreign_key_constraint(:id,
      message: dgettext("specialities", "Cannot delete speciality with related groups")
    )
  end
end
