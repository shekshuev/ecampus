defmodule Ecampus.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :begin_date, :utc_datetime
      add :end_date, :utc_datetime
      add :classroom, :string
      add :group_id, references(:groups, on_delete: :nothing)
      add :lesson_id, references(:lessons, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:classes, [:group_id])
    create index(:classes, [:lesson_id])
  end
end
