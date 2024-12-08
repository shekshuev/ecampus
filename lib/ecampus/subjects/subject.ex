defmodule Ecampus.Subjects.Subject do
  @moduledoc """
  The Subject context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "subjects" do
    field :description, :string
    field :title, :string
    field :short_title, :string
    field :prerequisites, :string
    field :objectives, :string
    field :required_texts, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [
      :title,
      :short_title,
      :description,
      :prerequisites,
      :objectives,
      :required_texts
    ])
    |> validate_required([
      :title,
      :short_title,
      :description,
      :prerequisites,
      :objectives,
      :required_texts
    ])
  end
end
