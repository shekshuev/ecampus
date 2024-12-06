defmodule Ecampus.Repo.Migrations.CreateSpecialities do
  use Ecto.Migration

  def change do
    create table(:specialities) do
      add :code, :string
      add :description, :text
      add :title, :string

      timestamps(type: :utc_datetime)
    end
  end
end
