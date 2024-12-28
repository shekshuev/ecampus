defmodule Ecampus.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :type, :string
      add :title, :string
      add :subtitle, :string
      add :grade, :integer
      add :show_correct_answer, :boolean, default: false, null: false
      add :quiz_id, references(:quizzes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:questions, [:quiz_id])
  end
end
