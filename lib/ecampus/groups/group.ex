defmodule Ecampus.Groups.Group do
  @moduledoc """
  The Group context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :description, :string
    field :title, :string

    belongs_to(:speciality, Ecampus.Specialities.Speciality)
    has_many(:users, Ecampus.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:title, :description, :speciality_id])
    |> validate_required([:title, :description, :speciality_id])
    |> assoc_constraint(:speciality)
  end
end
