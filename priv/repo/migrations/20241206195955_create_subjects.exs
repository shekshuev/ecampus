defmodule Ecampus.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects) do
      add :title, :string
      add :short_title, :string
      add :description, :text
      add :prerequisites, :text
      add :objectives, :text
      add :required_texts, :text

      timestamps(type: :utc_datetime)
    end
  end
end
