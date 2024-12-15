defmodule Ecampus.Repo.Migrations.CreateLessonTopics do
  use Ecto.Migration

  def change do
    create table(:lesson_topics) do
      add :title, :string
      add :content, :text
      add :sort_order, :integer
      add :lesson_id, references(:lessons, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_topics, [:lesson_id])
  end
end
