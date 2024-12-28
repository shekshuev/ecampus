defmodule Ecampus.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      add :title, :string
      add :description, :string
      add :questions_per_attempt, :integer
      add :lesson_id, references(:lessons, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:quizzes, [:lesson_id])
  end
end
