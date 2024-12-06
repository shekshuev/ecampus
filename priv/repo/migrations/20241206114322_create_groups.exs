defmodule Ecampus.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :title, :string
      add :description, :text
      add :speciality_id, references(:specialities, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:groups, [:speciality_id])
  end
end
