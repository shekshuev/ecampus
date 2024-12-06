defmodule Ecampus.Specialities.Speciality do
  @moduledoc """
  The Speciality context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "specialities" do
    field :code, :string
    field :description, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(speciality, attrs) do
    speciality
    |> cast(attrs, [:code, :description, :title])
    |> validate_required([:code, :description, :title])
  end
end
