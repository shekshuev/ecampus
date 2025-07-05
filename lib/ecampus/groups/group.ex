defmodule Ecampus.Groups.Group do
  @moduledoc """
  The `Group` schema represents a student group in the Ecampus system.

  ## Fields

  - `title` – the name of the group (required).
  - `description` – an optional description of the group.
  - `speciality_id` – foreign key referring to the related speciality (required).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :speciality_id], sortable: [:id, :title]
  }

  @type t :: %__MODULE__{
          id: integer(),
          title: String.t(),
          description: String.t() | nil,
          speciality_id: integer(),
          speciality: Ecampus.Specialities.Speciality.t() | Ecto.Association.NotLoaded.t(),
          users: [Ecampus.Accounts.User.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "groups" do
    field :description, :string
    field :title, :string

    belongs_to :speciality, Ecampus.Specialities.Speciality
    has_many :users, Ecampus.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:title, :description, :speciality_id])
    |> validate_required([:title, :speciality_id])
    |> assoc_constraint(:speciality)
  end
end
