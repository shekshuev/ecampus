defmodule Ecampus.Repo.Migrations.CreateAnsweredQuestions do
  use Ecto.Migration

  def change do
    create table(:answered_questions, primary_key: false) do
      add :answer, :map
      add :user_id, references(:users, on_delete: :nothing), primary_key: true
      add :question_id, references(:questions, on_delete: :nothing), primary_key: true
      add :quiz_id, references(:quizzes, on_delete: :nothing), primary_key: true

      timestamps(type: :utc_datetime)
    end
  end
end
