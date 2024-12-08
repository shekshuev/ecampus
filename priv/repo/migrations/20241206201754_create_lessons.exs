defmodule Ecampus.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      add :title, :string
      add :topic, :text
      add :objectives, :text
      add :is_draft, :boolean, default: false, null: false
      add :hours_count, :integer, default: 2
      add :sort_order, :integer, default: 0
      add :subject_id, references(:subjects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:subject_id])
  end
end
