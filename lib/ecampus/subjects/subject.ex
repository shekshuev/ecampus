defmodule Ecampus.Subjects.Subject do
  @moduledoc """
  Schema for representing an academic subject.

  A subject typically includes:
    - `title`: the full name of the subject.
    - `short_title`: abbreviated version of the title.
    - `description`: what the subject is about.
    - `prerequisites`: prior knowledge or subjects required.
    - `objectives`: what the subject aims to teach.
    - `required_texts`: literature or materials needed.
    - `cover`: an optional URL or path to the subject's cover image.

  This schema is stored in the `"subjects"` table.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :short_title, :description], sortable: [:id, :title, :short_title]
  }

  @type t :: %__MODULE__{
          id: integer() | nil,
          title: String.t(),
          short_title: String.t(),
          description: String.t(),
          prerequisites: String.t(),
          objectives: String.t(),
          required_texts: String.t(),
          cover: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "subjects" do
    field :description, :string
    field :title, :string
    field :short_title, :string
    field :prerequisites, :string
    field :objectives, :string
    field :required_texts, :string
    field :cover, :string

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
      :required_texts,
      :cover
    ])
    |> validate_required([
      :title,
      :short_title
    ])
  end
end
